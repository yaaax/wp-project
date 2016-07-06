<?php

use Phinx\Seed\AbstractSeed;

/**
 * Generates random password
 * @param (int) $length
 * @param (string) $keyspace
 */
function random_password(
    $length,
    $keyspace = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
) {
    $str = '';
    $max = mb_strlen($keyspace, '8bit') - 1;
    if ($max < 1) {
        throw new Exception('$keyspace must be at least two characters long');
    }
    for ($i = 0; $i < $length; ++$i) {
        $str .= $keyspace[random_int(0, $max)];
    }
    return $str;
}

class InstallWordPressAndActivatePlugins extends AbstractSeed
{
    /**
     * Run Method.
     *
     * Write your database seeder using this method.
     *
     * More information on writing seeders is available here:
     * http://docs.phinx.org/en/latest/seeding.html
     */
    public function run()
    {
      // Get installation variables from ENVs or use the defaults
      $url = getenv('WP_HOME');
      $title = ( getenv('WP_TITLE') ? getenv('WP_TITLE') : "WordPress" );

      if ( getenv('SMTP_FROM') ) {
        $email = getenv('SMTP_FROM');
      } elseif ( getenv('WP_HOME') ) {
        $email = "admin@".parse_url(getenv('WP_HOME'))['host'];
      }

      // Use custom env to override these defaults
      $password = ( getenv('WP_ADMIN_PASSWORD') ? getenv('WP_ADMIN_PASSWORD') : random_password(15) );
      $username = ( getenv('WP_ADMIN_USER') ? getenv('WP_ADMIN_USER') : "admin" );

      // Install wordpress with wp-cli
      echo "Installing {$title}...\n";
      $result = system("wp core install --url={$url} --title={$title} --admin_user={$username} \
                              --admin_email={$email} --admin_password={$password}" );

      // Activate plugins if installation was successful
      if (strpos($result, "WordPress installed successfully") !== false) {
        echo "\nYou can log in with credentials: {$username} / {$password}\n\n";

        echo "Activating all installed plugins...\n";

        // Disable welcome mail when installing here
        $disable_mail_file = dirname(dirname(dirname(__FILE__))).'/tests/rspec/lib/disable-wp-mail.php';
        system("wp plugin activate --all --require={$disable_mail_file}");
      }

      // Activate default theme if it exists
      echo "Activating the default theme if WP_DEFAULT_THEME is set...\n";
      $theme_name = system("wp eval 'echo WP_DEFAULT_THEME;'",$retval);
      echo "\n";
      if ($retval === 0 && ! empty($theme_name) ) {
        system("wp theme activate {$theme_name}");
      }
    }
}
