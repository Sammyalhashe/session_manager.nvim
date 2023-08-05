local status, pickers = pcall(require, "telescope.pickers")
if not status then return nil end

local actions = require("telescope.actions")
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local finders = require("telescope.finders")

local session_manager = require("session_manager")

local M = {}

local function runWithTelescope(selections, cb, prompt)
    local entry_maker = function(entry)
        return {
            value = entry,
            display = entry,
            ordinal = entry,
        }
    end
    local opts = {}
    pickers.new(opts, {
        prompt_title = prompt,
        finder = finders.new_table {
            results = selections,
            entry_maker = entry_maker
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = cb
    }):find()
end


function M.chooseSession(sessions)
    local action = function(prompt_bufnr, map)
        actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            session_manager.openSession(selection.value)
        end)
        return true
    end
    runWithTelescope(sessions, action, "Choose session")
end

function M.deleteSession(sessions)
    local action = function(prompt_bufnr, map)
        actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            session_manager.removeSession(selection.value)
        end)
        return true
    end
    runWithTelescope(sessions, action, "Choose session to delete")
end

return M
