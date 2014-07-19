trace.enter_action { module = "auditor", action = "generate_new_invite_code" }

local id = param.get_id()
local member = Member:by_id(id)

trace.debug("sending new invitation to "..id)
if not member then
	slot.put_into("error", _"Invalid member selected. Id: "..tostring(id))
	return
end
  
  member.invite_code = multirand.string( 24, "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
  member.invite_code_expiry = db:query("SELECT now() + '1 days'::interval as expiry", "object").expiry
  member:save()
  
  local parelonBaseUrl = "https://test.parelon.com/lf/"
  local subject = config.mail_subject_prefix .. _"Invitation to Parlamento Elettronico Online"
  local content = slot.use_temporary(function()
      slot.put(_"Hello\n\n")
      slot.put(_"You are invited to Parlamento Elettronico Online. To register please click the following link:\n\n")
      slot.put(parelonBaseUrl .. "index/register.html?invite=" .. member.invite_code .. "\n\nbefore 24h.")
      slot.put(_"\n\nIf this link is not working, please open following url in your web browser:\n\n")
      slot.put(parelonBaseUrl .. "index/register.html\n\n")
      slot.put(_"On that page please enter the invite key:\n\n")
      slot.put(member.invite_code .. "\n\nBest wishes.\n\nParelon Team")
    end)
  
  local success
  if member.notify_email_unconfirmed then
    success = net.send_mail{
    envelope_from = config.mail_envelope_from,
    from          = config.mail_from,
    reply_to      = config.mail_reply_to,
    to            = member.notify_email_unconfirmed,
    subject       = subject,
    content_type  = "text/plain; charset=UTF-8",
    content       = content
  }
  
else	
  success = net.send_mail{
    envelope_from = config.mail_envelope_from,
    from          = config.mail_from,
    reply_to      = config.mail_reply_to,
    to            = member.notify_email,
    subject       = subject,
    content_type  = "text/plain; charset=UTF-8",
    content       = content
  }
end
if not success then
	slot.put_into("error", "New invitation code not sent nor to "..member.notify_email .. " nor to " .. member.notify_email_unconfirmed ..".")
else
	slot.put_into("notice", "New invitation code sent.")
end
