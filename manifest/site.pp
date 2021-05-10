if $::kernel == 'windows' {
  Package { provider => chocolatey, }
}

file { 'C:/Puppet.txt':
  ensure  => present,
  content => 'Managed by Puppet',
  owner   => system,
}

file { 'C:/Puppet':
  ensure => directory,
  owner  => system,
}

file { 'C:/Git':
  ensure => directory,
  owner  => 'system',
  group  => 'Administrators',
  mode   => '0644',
}

class { 'chocolatey':
  chocolatey_download_url       => 'https://chocolatey.org/api/v2/package/chocolatey', # Should set to internal repo
  use_7zip                      => false,
  choco_install_timeout_seconds => 600,
}

package {'chocolatey':
  ensure => latest,
}

chocolateysource {'chocolatey':
  ensure => disabled,
}

chocolateysource {'chocolatey_local':
  ensure   => present,
  location => 'https://chocolatey.local/chocolatey',
}

chocolateyfeature {'showDownloadProgress':
  ensure => disabled,
}

chocolateyfeature {'useRememberedArgumentsForUpgrades':
  ensure => enabled,
}

# Packages
package { 'git':
  ensure          => latest,
  install_options => ['--params',
  '"',
  '/GitAndUnixToolsOnPath',
  '/NoShellIntegration',
  '/WindowsTerminal',
  '/NoCredentialManager',
  '/NoGitLfs',
  '/SChannel',
  '"'],
}

package { 'nodejs-lts':
  ensure => '14.16.1',
}

windows_env { [
  'PATH=C:\Program Files\Git\cmd',
  'PATH=C:\Program Files\Git\usr\bin',
]:
  ensure  => present,
  require => Package['git'],
}

vcsrepo { 'C:/Git/control-repo':
  ensure   => latest,
  provider => git,
  revision => 'production',
  source   => 'https://github.com/robertkg/control-repo.git',
  require  => Package['git'],
}
