<?php
# Movable Type (r) Open Source (C) 2001-2009 Six Apart, Ltd.
# This program is distributed under the terms of the
# GNU General Public License, version 2.
#
# $Id: function.mtpingscorelow.php 106007 2009-07-01 11:33:43Z ytakayama $

require_once('rating_lib.php');

function smarty_function_mtpingscorelow($args, &$ctx) {
    return hdlr_score_low($ctx, 'tbping', $args['namespace'], $args);
}
?>
