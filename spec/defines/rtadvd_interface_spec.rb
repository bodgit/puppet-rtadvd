require 'spec_helper'

describe 'rtadvd::interface' do

  let(:pre_condition) do
    'include ::rtadvd'
  end

  let(:title) do
    'em0'
  end

  let(:params) do
    {
      'dnssl'               => [
        'example.com',
      ],
      'other_configuration' => true,
      'rdnss'               => [
        '2001:db8::1',
        '2001:db8::2',
      ],
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}", :compile do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_rtadvd__interface('em0') }

      case facts[:osfamily]
      when 'OpenBSD'
        it {
          should contain_concat__fragment('rtadvd interface em0').with_content(<<~'EOS')
            em0:\
            	:raflags#64:\
            	:rdnss="2001:db8::1,2001:db8::2":\
            	:dnssl="example.com":
          EOS
        }
        it { should contain_datacat_fragment('rtadvd interface em0') }
      when 'RedHat'
        it {
          should contain_concat__fragment('rtadvd interface em0').with_content(<<~'EOS')
            interface em0 {
            	AdvSendAdvert on;
            	AdvManagedFlag off;
            	AdvOtherConfigFlag on;
            	prefix ::/64 {
            		AdvOnLink on;
            		AdvAutonomous on;
            		AdvRouterAddr on;
            	};
            	RDNSS 2001:db8::1 2001:db8::2 {
            	};
            	DNSSL example.com {
            	};
            };
          EOS
        }
      end
    end
  end
end
