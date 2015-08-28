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
      'other_configuration' => true,
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}", :compile do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_concat__fragment('rtadvd interface em0') }
      it { should contain_rtadvd__interface('em0') }

      case facts[:osfamily]
      when 'OpenBSD'
        it { should contain_datacat_fragment('rtadvd interface em0') }
        #it { should contain_service('rtadvd').with_flags('em0') }
      else
      end
    end
  end
end
