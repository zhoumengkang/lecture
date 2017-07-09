<?php
/**
 * Created by PhpStorm.
 * User: mengkang <i@mengkang.net>
 * Date: 2017/7/9 下午2:04
 */

    define('USER_DB','user_db');
    define('RANK_DB','rank_db');



    $dbConfig = [];

    $dbConfig[USER_DB] = [
        'write' => [
            'host'     => '',
            'port'     => '',
            'dbname'   => '',
            'username' => '',
            'password' => '',
        ],
        'read'  => [
            [
                'host'     => '',
                'port'     => '',
                'dbname'   => '',
                'username' => '',
                'password' => '',
            ],
            [
                'host'     => '',
                'port'     => '',
                'dbname'   => '',
                'username' => '',
                'password' => '',
            ],
        ],
    ];

    return $dbConfig;



