require 'spec_helper'

describe 'duo_authproxy::install' do
  let(:pre_condition) { 'include duo_authproxy' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        if os_facts[:osfamily] == 'RedHat'
          it { is_expected.to contain_package('gcc') }
          it { is_expected.to contain_package('libffi-devel') }
        elsif os_facts[:osfamily] == 'Debian'
          it { is_expected.to contain_package('build-essential') }
          it { is_expected.to contain_package('libffi-dev') }
        end
        it { is_expected.to contain_archive('/tmp/duoauthproxy-2.7.0-src.tgz') }
        it { is_expected.to contain_exec('duoauthproxy-install').with_command(%r{--install-dir /opt/duoauthproxy}) }
      end
    end
  end
end
