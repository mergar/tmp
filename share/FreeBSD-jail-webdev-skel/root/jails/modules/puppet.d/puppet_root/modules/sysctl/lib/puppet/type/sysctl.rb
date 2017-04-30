#
module Puppet
	newtype(:sysctl) do
		@doc = "Manages the contents of /etc/sysctl.conf"

		ensurable

		newparam(:name) do
			desc "Name of kernel parameter"

			isnamevar

		end

		newproperty(:value) do
			desc "Sets parameter to this value"
		end

		newproperty(:target) do
			desc "Location of sysctl configuration file"
			defaultto {
				if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
					@resource.class.defaultprovider.default_target
				else
					nil
				end
			}
		end
	end
end
