local utils = require("utils")

local cmd = vim.cmd
local fn = vim.fn

--> Module level variables
local session_dir = "~/.sessions/"

local M = {}
M.current_session = nil

function M.setup(opts)
    if opts.session_dir then
        session_dir = opts.session_dir
    end

    if opts.mappings then
        local mappings = opts.mappings
        for k, v in pairs(mappings) do
            if k == "chooseSession" then
                vim.keymap.set('n', v, M.chooseSession)
            elseif k == "saveSession" then
                vim.keymap.set('n', v, M.saveSession)
            elseif k == "deleteSession" then
                vim.keymap.set('n', v, M.deleteSession)
            elseif k == "newSession" then
                vim.keymap.set('n', v, M.newSession)
            end
        end
    end

    if opts.override_selector then
        M.override_selector = opts.override_selector
    end

    utils.mkdir(session_dir, "p")
end

--> local functions that depend on the setup state
local function sessionExists(sessionName)
    return utils.file_exists(utils.expandFilePath(session_dir) .. sessionName)
end

local function getAllSessions()
    return fn.split(fn.glob(session_dir .. "*"))
end

local function buildSessionPrompt(sessions)
    local prompt = ""
    for i, session in pairs(sessions) do
        prompt = prompt .. "&" .. i .. " " .. session .. "\n"
    end
    return prompt
end

--> exposed module functions.
function M.openSession(sessionName)
    local previous_session = M.current_session
    cmd.source(sessionName)
    if vim.g.errmsg ~= "" then
        -- session failed to load for some reason, switch back
        if previous_session ~= nil then
            cmd.source(previous_session)
        end
        return
    end
    M.current_session = sessionName
    local s, notes = pcall(require, "notes_for_projects")
    if s then
        local session_split = utils.split_string(sessionName, "/")
        local actual_session_name = utils.split_string(session_split[#session_split], ".")[1]
        notes.setProject(actual_session_name, {
            createDir = true,
        })
    end
end

function M.removeSession(sessionName)
    local prompt = "&y\n&n\n"
    local res = fn.confirm("Confirm deletion: " .. sessionName .. "?", prompt)

    if (res > 1) then
        return
    end

    fn.delete(sessionName)
end

function M.overwriteSession(sessionName)
    cmd("mks! " .. utils.expandFilePath(session_dir) .. sessionName)
    M.current_session = sessionName
    local s, notes = pcall(require, "notes_for_projects")
    if s then
        local session_split = utils.split_string(sessionName, "/")
        local actual_session_name = utils.split_string(session_split[#session_split], ".")[1]
        notes.setProject(actual_session_name, {
            createDir = true,
        })
    end
end

function M.chooseSession()
    local sessions = getAllSessions()
    if M.override_selector then
        M.override_selector.chooseSession(sessions)
        return
    end
    local prompt = buildSessionPrompt(sessions)
    local res = fn.confirm("Selected the session to open: ", prompt)
    M.openSession(sessions[res])
end

function M.saveSession()
    local sessionName = nil
    if M.current_session then
        local split_string = utils.split_string(M.current_session, "/")
        sessionName = split_string[#split_string]
    else
        sessionName = fn.input("Enter the name of the session: ")
    end

    local prompt = "&y\n&n\n"
    local res = fn.confirm("Confirm choice: " .. sessionName .. "?", prompt)

    if (res > 1) then
        return
    end

    M.overwriteSession(sessionName)
end

function M.newSession()
    local sessionName = fn.input("Enter the name of the session: ")
    if utils.file_exists(utils.expandFilePath(session_dir) .. sessionName) then
        print("Session already exists... aborting")
        return
    end
    local prompt = "&y\n&n\n"
    local res = fn.confirm("Confirm choice: " .. sessionName .. "?", prompt)

    if (res > 1) then
        return
    end

    M.overwriteSession(sessionName)
end

function M.deleteSession()
    local sessions = getAllSessions()
    if M.override_selector then
        M.override_selector.deleteSession(sessions)
        return
    end
    local prompt = buildSessionPrompt(sessions)
    local res = fn.confirm("Choose the session to delete: ", prompt)

    local sessionName = sessions[res]

    M.removeSession(sessionName)
end

return M
