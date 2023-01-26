--  
--  BotSay Usage
--  
--  Description:
--      BotSay is a function custom made for the DFCP Discord server that will connect to a webhook on DFCP and allow
--      a message to be sent to the configured channel.
--  
--  Usage:
--      simply attach this script file in the mission triggers AFTER any MOOSE or MIST initializations but BEFORE the custom mission scripts
--      
--      In your code/trigger just run
--          BotSay("Hello world")
--      
--      A message should be sent out to DFCP. The string inside the "" can be any text string with a max of 512 characters
--  

local localWebhooklocation = 'E:\\"Saved Games"\\DCS\\Scripts\\DiscordSendWebhook.exe'
local Proxy404ServerWebhookExe = "G:\\DiscordSendWebhook\\DiscordSendWebhook.exe"

local DFCPMissionMessagesWebhook = "https://discord.com/api/webhooks/938214134200270908/Mtc5z50ONfTRE6K_7T0XnOIxG0BGKT-0qLXjKIWeOhx95HwzHjFgkZDxTc9wd5TucmKa"
local DFCPRacingLegueWebhook = "https://discord.com/api/webhooks/1017324279202844732/00qKlRUKdPZbHCVju4f5apQ7PiajU41b9TL_iD6X6PHy5ZdayI61_C4tMhjl6RS0poTy"

function repl(dirty)--overly visual function to remove specific special characters 
    local text = dirty:gsub("&", ""):gsub('"', ""):gsub("'", ""):gsub("%%", ""):gsub("/", ""):gsub("\\", ""):gsub(">", "") --:gsub("|", " ")
    local clean = text:gsub("<", "")
    return clean
end

function BotSay(msg)
    dfcp_logger("BotSay - message received - " .. msg)
    local message = repl(msg)
    dfcp_logger("BotSay - message cleaned - " .. message)
    local text = Proxy404ServerWebhookExe .. ' -m "' .. message .. '" -w "' .. DFCPRacingLegueWebhook ..'"'
    dfcp_logger("BotSay - attempting to execute: "..text)
    os.execute(text)
end
