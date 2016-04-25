SCHEDULER.every '1m', :first_in => 0 do

require 'aws-sdk'

support = Aws::Support::Client.new({
    region: <region>,
    access_key_id: <access_key>,
    secret_access_key: <secret_key>,
})

check_id = ''

# Get the Check ID for Service Limit
resp = support.describe_trusted_advisor_checks({
  language: "en",
})

resp.checks.each do |check|
    if check.name == "Service Limits"
        check_id = check.id
    end
end

# ID for Service Limits check from Trusted Advisor
resp = support.describe_trusted_advisor_check_result({
    check_id: check_id,
})

serviceLimitsAlerts = Array.new

flaggedResources = resp.result.flagged_resources

flaggedResources.each do |alerts|
    if alerts.status != 'ok'
	# Get the region and the service limit name from trusted advisor
	serviceLimitsAlerts.push region: alerts.region, serviceLimitName: alerts.metadata[2] + '-' + alerts.metadata[1]
    end
end

send_event("trustedAdvisor", { checks: serviceLimitsAlerts})

end
