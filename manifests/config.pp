class letsencrypt_aws::config (){

  exec { 'register':
    command => "python /opt/letsencrypt_aws/letsencrypt-aws.py register ${letsencrypt_aws::email} > /tmp/output.txt",
    unless  => 'openssl rsa -noout -text -in /opt/letsencrypt_aws/acme.pem 2>/dev/null | grep Private',
    path    => '/usr/bin/:/bin/',
    notify  => Exec['strip'],
  }

  exec { 'strip':
    command     => 'sed \'/acme-register/d\' /tmp/output.txt > /opt/letsencrypt_aws/acme.pem',
    path        => '/bin/',
    refreshonly => true,
    notify      => Exec['create-listener']
  }

  file {
    '/opt/letsencrypt_aws/config.json':
      ensure  => file,
      content => template('letsencrypt_aws/config.json.erb'),
      owner   => root,
      group   => root,
      mode    => '0755';
  }

  exec { 'create-listener':
    command     => 'python /opt/letsencrypt_aws/letsencrypt-aws.py update-certificates --force-issue --create-listener',
    environment => [ "AWS_DEFAULT_REGION=${::region};LETSENCRYPT_AWS_CONFIG=`cat /opt/letsencrypt_aws/config.json`" ],
    path        => '/usr/bin/:/bin/',
    refreshonly => true,
    require     => [File['/opt/letsencrypt_aws/config.json'], Exec['register'], Exec['strip']]
  }

  cron { 'renew-cert':
    ensure      => present,
    command     => '/usr/bin/python /opt/letsencrypt_aws/letsencrypt-aws.py update-certificates >> /var/log/letsencrypt_aws.log',
    environment => [ "AWS_DEFAULT_REGION=${::region};LETSENCRYPT_AWS_CONFIG=`cat /opt/letsencrypt_aws/config.json`" ],
    user        => 'root',
    hour        => 1,
    minute      => 0,
  }
}
