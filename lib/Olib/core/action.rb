module Action
  def self.try_or_fail(seconds: 5, command: nil)
    fput(command)
    expiry = Time.now + seconds
    wait_until do yield or Time.now > expiry end
    Err[command: command, seconds: seconds, reason: :not_found] if Time.now > expiry
  end
end