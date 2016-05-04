# puppet-letsencrypt_aws

Install letsencrypt on AWS ELB with puppet

We use [this open-source project](https://github.com/skyscrapers/letsencrypt-aws)

## Usage

```
$elbs = {
  'elb-name' => ['domain1.com','example.domain1.com'],
  'elb-name2' => ['domain2.com'],
 }

class {'letsencrypt_aws':
  email  => 'email@domain.com',
  elbs   => $elbs,
  region => 'eu-west-1',
}
```

This will setup the listener on port 443 and add your cert. Afterwards it will create a cronjob to regularly check the SSL cert status.

Make sure the instance you install this on has the following [IAM policy](https://github.com/skyscrapers/letsencrypt-aws#iam-policy):
