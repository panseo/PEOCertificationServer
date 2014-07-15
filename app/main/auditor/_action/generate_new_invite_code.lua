local id = param.get_id()
local member = Member:by_id(id)

trace.debug("sending new invitation to "..id)
if not member then
	slot.put_into("error", _"Invalid member selected. Id: "..tostring(id))
	return
end

member:send_invitation()

trace.debug("result: "..result)

if not result then
	slot.put_into("error", _"New invitation code not sent.")
else
	slot.put_into("notice", _"New invitation code sent.")
end
