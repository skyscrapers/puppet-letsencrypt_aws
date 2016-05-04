class letsencrypt_aws::install (){
  $packages = ['python-dev', 'libffi-dev', 'libssl-dev']
  $pippackages = ['setuptools', 'requests']

  package { $packages :
    ensure => installed,
  }

  if !defined(Package['git']) {
    package { 'git' :
      ensure => installed,
    }
  }

  if !defined(Package['python-pip']) {
    package { 'python-pip' :
      ensure => installed,
      notify => Exec['install pip'],
    }
  }

  exec { 'install pip':
    command     => 'pip install pip --upgrade',
    path        => '/usr/bin/',
    require     => Package['python-pip'],
  }

  package { $pippackages:
    ensure   => latest,
    provider => pip,
    require  => Exec['install pip']
  }

  vcsrepo { '/opt/letsencrypt_aws':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/skyscrapers/letsencrypt-aws.git',
    revision => 'master',
    require  => Package['git'],
    notify   => Exec['pip_requirements_install']
  }

  exec { 'pip_requirements_install':
    command     => 'pip install -r /opt/letsencrypt_aws/requirements.txt',
    path        => '/usr/local/bin/:/usr/bin/',
    require     => Exec['install pip'],
    refreshonly => true,
  }
}
