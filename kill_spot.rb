require_relative 'aws_conf'
require 'aws-sdk'

debug = false
debug = true

FILENAME = '.spot_status'

AWS.config(
  :access_key_id => AWS_CONF::ACCESS_KEY_ID,
  :secret_access_key => AWS_CONF::SECRET_ACCESS_KEY,
  :region => AWS_CONF::REGION)

ec2 = AWS.ec2.client

status_file = File.open(FILENAME)
status_file.each_line do |line|
  if line.split(" ").first == "spot"
    puts "Canceling spot request"
    ec2.cancel_spot_instance_requests(
      :spot_instance_request_ids => [line.split(" ")[1].strip])
  else
    puts "Terminating instance"
    ec2.terminate_instances(
      :instance_ids => [line.strip])
  end
end
status_file.close

`rm #{FILENAME}`
