<?php
# Movable Type (r) Open Source (C) 2001-2009 Six Apart, Ltd.
# This program is distributed under the terms of the
# GNU General Public License, version 2.
#
# $Id: mtcache_base.php 106007 2009-07-01 11:33:43Z ytakayama $

class MTCacheBase {
    var $_ttl = 0;

    function MTCacheBase ($ttl = 0) {
        $this->ttl = $ttl;
    }

    function get ($key, $ttl = null) {
    }

    function get_multi ($keys, $ttl = null) {
    }

    function delete ($key) {
    }

    function add ($key, $val, $ttl = null) {
    }

    function replace ($key, $val, $ttl = null) {
    }

    function set ($key, $val, $ttl = null) {
    }

    function flush_all() {
    }
}
?>
