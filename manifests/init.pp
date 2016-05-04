class letsencrypt_aws(
  $email  = undef,
  $elbs   = undef,
  $region = undef,
  ){
  contain letsencrypt_aws::install
  contain letsencrypt_aws::config

  Class[letsencrypt_aws::install] -> Class[letsencrypt_aws::config]
}
