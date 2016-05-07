<?php
/**
 * Custom WordPress install script. This is WordPress drop-in install.php file.
 * Drop-ins are advanced plugins in the wp-content directory that replace WordPress functionality when present.
 *
 * @author Onni Hakala / Geniem Oy
 * @package devgeniem/wp-project
 */

/**
 * Installs the site.
 *
 * Runs the required functions to set up and populate the database,
 * including primary admin user and initial options.
 *
 * @since 2.1.0
 *
 * @param string $blog_title    Blog title.
 * @param string $user_name     User's username.
 * @param string $user_email    User's email.
 * @param bool   $public        Whether blog is public.
 * @param string $deprecated    Optional. Not used.
 * @param string $user_password Optional. User's chosen password. Default empty (random password).
 * @param string $language      Optional. Language chosen. Default empty.
 * @return array Array keys 'url', 'user_id', 'password', and 'password_message'.
 */
function wp_install( string $blog_title, string $user_name, string $user_email, bool $public,
    string $deprecated = '', string $user_password = '', string $language = '' ) {

  if ( ! empty( $deprecated ) ) {
    _deprecated_argument( __FUNCTION__, '2.6' );
  }

  wp_check_mysql_version();
  wp_cache_flush();
  make_db_current_silent();
  populate_options();
  populate_roles();

  if ( $language ) {
    update_option( 'WPLANG', $language );
  } elseif ( env( 'WPLANG' ) ) {
    update_option( 'WPLANG', env( 'WPLANG' ) );
  }

  update_option( 'blogname', $blog_title );
  update_option( 'admin_email', $user_email );
  update_option( 'blog_public', $public );

  // Prefer empty description if someone forgots to change it.
  update_option( 'blogdescription', '' );

  $guessurl = wp_guess_url();

  update_option( 'siteurl', $guessurl );

  // If not a public blog, don't ping.
  if ( ! $public ) {
    update_option( 'default_pingback_flag', 0 );
  }

  /*
   * Create default user. If the user already exists, the user tables are
   * being shared among blogs. Just set the role in that case.
   */
  $user_id = username_exists( $user_name );
  $user_password = trim( $user_password );
  $email_password = false;
  if ( ! $user_id && empty( $user_password ) ) {
    $user_password = wp_generate_password( 12, false );
    $message = __('<strong><em>Note that password</em></strong> carefully! It is a <em>random</em> password that was generated just for you.');
    $user_id = wp_create_user($user_name, $user_password, $user_email);
    update_user_option($user_id, 'default_password_nag', true, true);
    $email_password = true;
  } elseif ( ! $user_id ) {
    // Password has been provided.
    $message = '<em>'.__('Your chosen password.').'</em>';
    $user_id = wp_create_user($user_name, $user_password, $user_email);
  } else {
    $message = __('User already exists. Password inherited.');
  }

  $user = new WP_User($user_id);
  $user->set_role('administrator');

  wp_install_defaults($user_id);

  wp_install_maybe_enable_pretty_permalinks();

  flush_rewrite_rules();

  wp_cache_flush();

  /**
   * Fires after a site is fully installed.
   *
   * @since 3.9.0
   *
   * @param WP_User $user The site owner.
   */
  do_action( 'wp_install', $user );

  return array( 'url' => $guessurl, 'user_id' => $user_id, 'password' => $user_password, 'password_message' => $message );
}

/**
 * Creates the initial content for a newly-installed site.
 *
 * Adds the default "Uncategorized" category, the first post (with comment),
 * first page, and default widgets for default theme for the current version.
 *
 * @since 2.1.0
 *
 * @param int $user_id User ID.
 */
function wp_install_defaults( int $user_id ) {
  global $wpdb, $wp_rewrite, $current_site, $table_prefix;

  /**
   * Time zone: Get the one from docker TZ variable
   *
   * @see wp-admin/options-general.php
   */
  update_option( 'timezone_string', env('TZ') );

  /**
   * Before a comment appears a comment must be manually approved: true
   *
   * @see wp-admin/options-discussion.php
   */
  update_option( 'comment_moderation', 1 );

  /** Before a comment appears the comment author must have a previously approved comment: false */
  update_option( 'comment_whitelist', 0 );

  /** Allow people to post comments on new articles (this setting may be overridden for individual articles): false */
  update_option( 'default_comment_status', 0 );

  /** Allow link notifications from other blogs: false */
  update_option( 'default_ping_status', 0 );

  /** Attempt to notify any blogs linked to from the article: false */
  update_option( 'default_pingback_flag', 0 );

  /**
   * Organize my uploads into month- and year-based folders: true
   *
   * @see wp-admin/options-media.php
   */
  update_option( 'uploads_use_yearmonth_folders', 1 );

  /**
   * Permalink custom structure: /%postname%
   *
   * @see wp-admin/options-permalink.php
   */
  update_option( 'permalink_structure', '/%postname%/' );

  // Default category.
  $cat_name = __('Uncategorized');
  /* translators: Default category slug */
  $cat_slug = sanitize_title( _x('Uncategorized', 'Default category slug') );

  if ( global_terms_enabled() ) {
    $cat_id = $wpdb->get_var( $wpdb->prepare( "SELECT cat_ID FROM {$wpdb->sitecategories} WHERE category_nicename = %s", $cat_slug ) );
    if ( null == $cat_id ) {
      $wpdb->insert( $wpdb->sitecategories, array( 'cat_ID' => 0, 'cat_name' => $cat_name, 'category_nicename' => $cat_slug, 'last_updated' => current_time('mysql', true) ) );
      $cat_id = $wpdb->insert_id;
    }
    update_option('default_category', $cat_id);
  } else {
    $cat_id = 1;
  }

  $wpdb->insert( $wpdb->terms, array( 'term_id' => $cat_id, 'name' => $cat_name, 'slug' => $cat_slug, 'term_group' => 0 ) );
  $wpdb->insert( $wpdb->term_taxonomy, array( 'term_id' => $cat_id, 'taxonomy' => 'category', 'description' => '', 'parent' => 0, 'count' => 1 ) );
  $cat_tt_id = $wpdb->insert_id;

  // First post
  $now = current_time( 'mysql' );
  $now_gmt = current_time( 'mysql', 1 );
  $first_post_guid = get_option( 'home' ) . '/?p=1';

  if ( is_multisite() ) {
    $first_post = get_site_option( 'first_post' );

    if ( ! $first_post ) {
      /* translators: %s: site link */
      $first_post = __( 'Welcome to %s. This is your first post. Edit or delete it, then start blogging!' );
    }

    $first_post = sprintf( $first_post,
      sprintf( '<a href="%s">%s</a>', esc_url( network_home_url() ), get_current_site()->site_name )
    );

    // Back-compat for pre-4.4
    $first_post = str_replace( 'SITE_URL', esc_url( network_home_url() ), $first_post );
    $first_post = str_replace( 'SITE_NAME', get_current_site()->site_name, $first_post );
  } else {
    $first_post = '<span>New is always better</span></br>
        <small>- <a href="https://www.youtube.com/watch?v=rxBvgCyERkw">Barney Stinson</small>';
  }

  $wpdb->insert( $wpdb->posts, array(
      'post_author' => $user_id,
      'post_date' => $now,
      'post_date_gmt' => $now_gmt,
      'post_content' => $first_post,
      'post_excerpt' => '',
      'post_title' => __('Hello WordPress!'),
      /* translators: Default post slug */
      'post_name' => sanitize_title( _x('hello-wordpress', 'Default post slug') ),
      'post_modified' => $now,
      'post_modified_gmt' => $now_gmt,
      'guid' => $first_post_guid,
      'comment_count' => 0,
      'to_ping' => '',
      'pinged' => '',
      'post_content_filtered' => '',
  ));
  $wpdb->insert( $wpdb->term_relationships, array( 'term_taxonomy_id' => $cat_tt_id, 'object_id' => 1 ) );

  // First Page
  $first_page = sprintf( __( "This is an example page. It's different from a blog post because it will stay in one place and will show up in your site navigation (in most themes). Most people start with an About page that introduces them to potential site visitors. It might say something like this:

<blockquote>Hi there! I'm a bike messenger by day, aspiring actor by night, and this is my website. I live in Los Angeles, have a great dog named Jack, and I like pi&#241;a coladas. (And gettin' caught in the rain.)</blockquote>

...or something like this:

<blockquote>The XYZ Doohickey Company was founded in 1971, and has been providing quality doohickeys to the public ever since. Located in Gotham City, XYZ employs over 2,000 people and does all kinds of awesome things for the Gotham community.</blockquote>

As a new WordPress user, you should go to <a href=\"%s\">your dashboard</a> to delete this page and create new pages for your content. Have fun!" ), admin_url() );

  if ( is_multisite() ) {
    $first_page = get_site_option( 'first_page', $first_page );
  }
  $first_post_guid = get_option('home') . '/?page_id=2';
  $wpdb->insert( $wpdb->posts, array(
      'post_author' => $user_id,
      'post_date' => $now,
      'post_date_gmt' => $now_gmt,
      'post_content' => $first_page,
      'post_excerpt' => '',
      'comment_status' => 'closed',
      'post_title' => __( 'Sample Page' ),
      /* translators: Default page slug */
      'post_name' => __( 'sample-page' ),
      'post_modified' => $now,
      'post_modified_gmt' => $now_gmt,
      'guid' => $first_post_guid,
      'post_type' => 'page',
      'to_ping' => '',
      'pinged' => '',
      'post_content_filtered' => '',
  ));
  $wpdb->insert( $wpdb->postmeta, array( 'post_id' => 2, 'meta_key' => '_wp_page_template', 'meta_value' => 'default' ) );

  // Set up default widgets for default theme.
  update_option( 'widget_search', array( 2 => array( 'title' => '' ), '_multiwidget' => 1 ) );
  update_option( 'widget_recent-posts', array( 2 => array( 'title' => '', 'number' => 5 ), '_multiwidget' => 1 ) );
  update_option( 'widget_recent-comments', array( 2 => array( 'title' => '', 'number' => 5 ), '_multiwidget' => 1 ) );
  update_option( 'widget_archives', array( 2 => array( 'title' => '', 'count' => 0, 'dropdown' => 0 ), '_multiwidget' => 1 ) );
  update_option( 'widget_categories', array( 2 => array( 'title' => '', 'count' => 0, 'hierarchical' => 0, 'dropdown' => 0 ), '_multiwidget' => 1 ) );
  update_option( 'widget_meta', array( 2 => array( 'title' => '' ), '_multiwidget' => 1 ) );
  update_option( 'sidebars_widgets', array( 'wp_inactive_widgets' => array(), 'sidebar-1' => array( 0 => 'search-2', 1 => 'recent-posts-2', 2 => 'recent-comments-2', 3 => 'archives-2', 4 => 'categories-2', 5 => 'meta-2' ), 'array_version' => 3 ) );

  if ( ! is_multisite() ) {
    update_user_meta( $user_id, 'show_welcome_panel', 1 );
  } elseif ( ! is_super_admin( $user_id ) && ! metadata_exists( 'user', $user_id, 'show_welcome_panel' ) ) {
    update_user_meta( $user_id, 'show_welcome_panel', 2 );
  }

  if ( is_multisite() ) {
    // Flush rules to pick up the new page.
    $wp_rewrite->init();
    $wp_rewrite->flush_rules();

    $user = new WP_User($user_id);
    $wpdb->update( $wpdb->options, array( 'option_value' => $user->user_email ), array( 'option_name' => 'admin_email' ) );

    // Remove all perms except for the login user.
    $wpdb->query( $wpdb->prepare("DELETE FROM $wpdb->usermeta WHERE user_id != %d AND meta_key = %s", $user_id, $table_prefix.'user_level') );
    $wpdb->query( $wpdb->prepare("DELETE FROM $wpdb->usermeta WHERE user_id != %d AND meta_key = %s", $user_id, $table_prefix.'capabilities') );

    // Delete any caps that snuck into the previously active blog. (Hardcoded to blog 1 for now.) TODO: Get previous_blog_id.
    if ( ! is_super_admin( $user_id ) && 1 != $user_id ) {
      $wpdb->delete( $wpdb->usermeta, array( 'user_id' => $user_id, 'meta_key' => $wpdb->base_prefix.'1_capabilities' ) );
    }
  }

  /**
   * Show welcome panel: false
   *
   * @see wp-admin/includes/screen.php
   */
  update_user_meta( $user_id, 'show_welcome_panel', 0 );
}
