require 'chef/knife'
require 'chef/data_bag_item'
require 'chef/search/query'
class ChefHelper

   # Keep last 10 code version deploy histories
   @@keep_history = 10
   
   # Update node codeversion attribute for a  node[] based on the query with role and environment as parameter
   def update_node_codeversion_recipes(service_role,env , codeversion)
      query="role:#{service_role} AND chef_environment:#{env}"
      ChefHelper.update_codeversion(query,codeversion,service_role)
   end


   # Update node codeversion attribute for a  node[] with a node array as parameter
   def update_node_codeversion_nodes(nodes , codeversion, service_role)
      query = String.new
      nodes_length = nodes.length
      nodes.each_with_index do |node ,index|
         query << " name:#{node}"
         query << " OR" if index  < nodes_length-1
      end
      ChefHelper.update_codeversion(query,codeversion,service_role)
   end

   # Update node codeversion attribute
   def self.update_codeversion(query,codeversion,service_role)
      query_nodes = Chef::Search::Query.new
      query_nodes.search('node', query) do |node_item|
         version = []
         if node_item["#{service_role}_code_version"] != nil
            version = node_item["#{service_role}_code_version"]
         end
         version << "#{codeversion}"
         version.shift(version.length-@@keep_history) if version.length > @@keep_history
         node_item.set["#{service_role}_code_version"] =version
         node_item.save
      end
   end

   # Check if the node[] is a part of the role|environment
   def valid_nodes(service_role,env ,nodes)
      valid_nodes =[]
      query="role:#{service_role} AND chef_environment:#{env}"
      query_nodes = Chef::Search::Query.new
      query_nodes.search('node', query) do |node_item|
         if nodes.include? node_item.name
            valid_nodes << node_item.name
         end
      end
      return valid_nodes
   end
end

