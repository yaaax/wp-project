<?php
/**
 * This is wrapper for bad plugins which require wp-load.php
 *
 * @author  Onni Hakala / Geniem Oy
 * @package geniem/wp-project
 */

/**
 * Usually wp-content is inside wordpress core but in this project wp-content
 * is moved out of core to be easier to update with composer.
 *
 * Layout looks like:
 * └── web
 *    ├── app
 *    │   ├── mu-plugins
 *    │   ├── plugins
 *    │   ├── themes
 *    │   └── languages
 *    ├── wp-config.php
 *    ├── index.php
 *    ├── wp-load.php
 *    └── wp # Wordpress Core installed by composer
 *        ├── wp-admin
 *        ├── index.php
 *        ├── wp-load.php
 *        └── ...
 * Some plugins have an antipattern to do this: require_once('../../../wp-load.php');
 * This is usually done to have some special ajax functionality.
 *
 * This file is where wp-load.php would typically be and fixes these problems
 * by requiring wp-load.php from where it really is.
 */
require_once( 'wp/wp-load.php' );
