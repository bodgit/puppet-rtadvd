require 'spec_helper'

describe 'rtadvd' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile }.to raise_error(/not supported on Unsupported/) }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}", :compile do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_class('rtadvd') }
      it { should contain_class('rtadvd::config') }
      it { should contain_class('rtadvd::install') }
      it { should contain_class('rtadvd::params') }
      it { should contain_class('rtadvd::service') }

      case facts[:osfamily]
      when 'OpenBSD'
        it { should contain_augeas('/etc/rc.conf.local/rtadvd_flags/empty') }
        it { should contain_augeas('/etc/rc.conf.local/rtadvd_flags/interfaces') }
        it { should contain_concat('/etc/rtadvd.conf') }
        it { should contain_datacat_collector('rtadvd interfaces').with(
          {
            'target_resource' => 'Augeas[/etc/rc.conf.local/rtadvd_flags/interfaces]',
            'target_field'    => 'changes',
          }
        ) }
        it { should contain_service('rtadvd') }
        it { should contain_sysctl('net.inet6.ip6.forwarding') }
        it { should have_package_resource_count(0) }
      else
        it { should contain_concat('/etc/radvd.conf') }
        it { should contain_package('radvd') }
        it { should contain_service('radvd') }
        it { should contain_sysctl('net.ipv6.conf.all.forwarding') }
        it { should have_augeas_resource_count(0) }
        it { should have_datacat_collector_resource_count(0) }
      end
    end
  end
end
