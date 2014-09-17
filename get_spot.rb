require_relative 'aws_conf'
require 'aws-sdk'

debug = false
debug = true

FILENAME = '.spot_status'
start_time = Time.now

AWS.config(
  :access_key_id => AWS_CONF::ACCESS_KEY_ID,
  :secret_access_key => AWS_CONF::SECRET_ACCESS_KEY,
  :region => AWS_CONF::REGION)

ec2 = AWS.ec2.client

unless File.exists?(FILENAME) and File.open(FILENAME, &:gets).split(" ").first == "spot"
  response = ec2.request_spot_instances(
#  :dry_run => true,
    :spot_price => AWS_CONF::SPOT_PRICE,
    :launch_specification => {
      :image_id => AWS_CONF::AMI,
      :instance_type => AWS_CONF::INSTNACE_TYPE,
      :subnet_id => AWS_CONF::SUBNET,
      :security_group_ids => [AWS_CONF::SECURITY_GROUP]})

  spot_request_id = response.data[:spot_instance_request_set].first[:spot_instance_request_id]

  puts "Spot ID:"
  puts spot_request_id

  outfile = File.new(FILENAME, 'w')
  outfile.puts "spot #{spot_request_id}"
  outfile.close
else
  spot_request_id = File.open(FILENAME, &:gets).split(" ")[1].strip
  puts "Spot request: #{spot_request_id} found"
end

instance_id = ""

#If we already have an instance ID in the status file, don't go looking
if `wc -l #{FILENAME}`.to_i >= 2
  instance_id = File.read(FILENAME).split("\n")[1].strip
  puts "Instance ID: #{instance_id} found"
else
  loop do
    status_response = ec2.describe_spot_instance_requests(
      :spot_instance_request_ids => [spot_request_id])
    status =  status_response[:spot_instance_request_set].first[:state]
    puts status
    if status == 'active'
      instance_id = status_response[:spot_instance_request_set].first[:instance_id]
      outfile = File.open(FILENAME, 'a')
      outfile.puts instance_id
      outfile.close
      break
    end
    sleep 10
  end
end

loop do
  instance_details = ec2.describe_instances(
    :instance_ids => [instance_id])[:reservation_set].first[:instances_set].first
  instance_state = instance_details[:instance_state][:name]
  puts instance_state
  if instance_state == "running"
    puts "Machine ready!  Time: #{Time.now - start_time} seconds"
    puts "SSH to: "
    puts "fedora@#{instance_details[:dns_name]}"
    break
  end
  sleep 10
end 
