<?php
/**
 * Plugin Name:  Global widget settings
 * Description:  Hack inactive widgets to get rid of wp error
 * Version:      1.0.0
 * Author:       Ville Pietarinen / Geniem Oy
 * Author URI:   https://geniem.com/
 * License:      MIT License
 */

add_action( 'init', function() {
	global $sidebars_widgets;
	if (!isset($sidebars_widgets['wp_inactive_widgets'])) {
		$sidebars_widgets['wp_inactive_widgets'] = [];
	}
});
