$:.unshift(File.dirname(__FILE__))
require 'fileutils'

def remote_file_exists?(url)
   url = URI.parse(url)
   Net::HTTP.start(url.host, url.port) do |http|
      return http.head(url.request_uri).code == "200"
   end
end

def is_artifact_there?(artifact_location)
   if artifact_location =~ /http/
      return remote_file_exists? artifact_location
   else
      return File.exists? artifact_location
   end
end

def fetch_artifact(artifact_location, dest)
   puts "Getting  *********************** artifact #{artifact_location} to #{dest}"
   # if artifact is local, just do cp. If it is in Artifactory, do wget
   if artifact_location =~ /http/
      filename = File.basename(artifact_location)
      set_artifactory_from_data_bag :"passwords"
      wget_command = "wget -O #{dest}/#{filename} #{artifact_location} --user=#{username} --password=#{pass}"
      #puts "wget_command is - > #{wget_command}"
      puts(wget_command)
      system(wget_command)
   elsif artifact_location
      FileUtils.cp(artifact_location, dest)
   end
   system("ls -l #{dest}")
end

def perform_service_action(service, action)
   run "sudo /sbin/service #{service} #{action}"
end

