<?php
/**
 * Created by PhpStorm.
 * User: mbs
 * Date: 10/1/15
 * Time: 9:30 PM
 */
/*
 * Filename: /rewrite-rules.php
 * REMEMBER TO SET YOUR PERMALINKS! Settings > Permalinks
 */
require( dirname( __FILE__ ) . '/wp-load.php' );

$rewrite_rules = get_option('rewrite_rules');

?>

<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Rewrite Rules</title>
    <style>
        td {text-align: left;}
        tr:nth-child(even) {background: #CDC}
        tr:nth-child(odd) {background: #CDF}
    </style>
</head>

<body>
    <table>
        <?php
            foreach ($rewrite_rules as $regex => $pattern) {
                echo "<tr><td>{$regex}</td><td>{$pattern}</td></tr>";
            }
        ?>
    </table>
</body>
</html>