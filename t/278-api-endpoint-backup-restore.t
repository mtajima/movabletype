#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib extlib t/lib);

use Data::Dumper;
use Test::More;
use MT::Test::DataAPI;

use MT::App::DataAPI;
my $app = MT::App::DataAPI->new;

my $suite = suite();
test_data_api( $suite, { author_id => 1, is_superuser => 1 } );

done_testing;

sub suite {
    return +[

        # backup_site - irregular tests.
        {    # Non-existent site.
            path   => '/v2/sites/10/backup',
            method => 'GET',
            code   => 404,
            result => sub {
                return +{
                    error => {
                        code    => 404,
                        message => 'Site not found',
                    },
                };
            },
        },
        {    # Invalid TmpDir.
            path   => '/v2/sites/1/backup',
            method => 'GET',
            setup  => sub { $app->config->TempDir('NON_EXISTENT_DIR') },
            code   => 409,
            result => sub {
                return +{
                    error => {
                        code => 409,
                        message =>
                            'Temporary directory needs to be writable for backup to work correctly.  Please check TempDir configuration directive.',
                    },
                };
            },
            complete => sub {
                $app->config->TempDir( $app->config->default('TempDir') );
            },
        },
        {    # Invalid backup_what.
            path   => '/v2/sites/0/backup',
            method => 'GET',
            params => { backup_what => '10', },
            code   => 400,
            result => sub {
                return +{
                    error => {
                        code    => 400,
                        message => 'Invalid backup_what: 10',
                    },
                };
            },
        },
        {    # Invalid backup_arhive_format.
            path   => '/v2/sites/1/backup',
            method => 'GET',
            params => { backup_archive_format => 'invalid', },
            code   => 400,
            result => sub {
                return +{
                    error => {
                        code    => 400,
                        message => 'Invalid backup_archive_format: invalid',
                    },
                };
            },
        },
        {    # Invalid limit_size.
            path   => '/v2/sites/1/backup',
            method => 'GET',
            params => { limit_size => 'invalid', },
            code   => 400,
            result => sub {
                return +{
                    error => {
                        code    => 400,
                        message => 'Invalid limit_size: invalid',
                    },
                };
            },
        },
        {    # Not logged in.
            path      => '/v2/sites/1/backup',
            method    => 'GET',
            author_id => 0,
            code      => 401,
            error     => 'Unauthorized',
        },
        {    # No permissions (site).
            path         => '/v2/sites/1/backup',
            method       => 'GET',
            is_superuser => 0,
            restrictions => { 1 => [qw/ backup_blog /], },
            code         => 403,
            error => 'Do not have permission to back up the requested site.',
        },
        {    # No permissions (system).
            path         => '/v2/sites/0/backup',
            method       => 'GET',
            is_superuser => 0,
            restrictions => { 0 => [qw/ backup_blog /], },
            code         => 403,
            error => 'Do not have permission to back up the requested site.',
        },

        # backup_site - normal tests.
        {    # Blog.
            path     => '/v2/sites/1/backup',
            method   => 'GET',
            complete => sub {
                my ( $data, $body ) = @_;

                ($body) = ( $body =~ m/(\{.+\})/ );
                my $got = $app->current_format->{unserialize}->($body);

                is( $got->{status}, 'success', 'status is success.' );
                is( scalar @{ $got->{backupFiles} },
                    3, 'Returned 3 backup files.' );

                print Dumper($got) . "\n";
            },
        },
        {    # Website.
            path     => '/v2/sites/2/backup',
            method   => 'GET',
            complete => sub {
                my ( $data, $body ) = @_;

                ($body) = ( $body =~ m/(\{.+\})/ );
                my $got = $app->current_format->{unserialize}->($body);

                is( $got->{status}, 'success', 'status is success.' );
                is( scalar @{ $got->{backupFiles} },
                    3, 'Returned 3 backup files.' );

                print Dumper($got) . "\n";
            },
        },
        {    # System.
            path     => '/v2/sites/0/backup',
            method   => 'GET',
            complete => sub {
                my ( $data, $body ) = @_;

                ($body) = ( $body =~ m/(\{.+\})/ );
                my $got = $app->current_format->{unserialize}->($body);

                is( $got->{status}, 'success', 'status is success.' );
                is( scalar @{ $got->{backupFiles} },
                    4, 'Returned 4 backup files.' );

                print Dumper($got) . "\n";
            },
        },

#        # restore_site - irregular tests.
#        {    # No file.
#            path   => '/v2/restore',
#            method => 'POST',
#            code   => 400,
#            result => sub {
#                return +{
#                    error => {
#                        code    => 400,
#                        message => 'A parameter "file" is required.',
#                    },
#                };
#            },
#        },
#        {    # Old schema version.
#            path   => '/v2/restore',
#            method => 'POST',
#            upload => [
#                'file',
#                File::Spec->catfile(
#                    $ENV{MT_HOME},                       "t",
#                    '278-api-endpoint-backup-restore.d', 'backup.xml'
#                ),
#            ],
#            code     => 500,
#            complete => sub {
#                my ( $data, $body ) = @_;
#
#                ($body) = ( $body =~ m/(\{.+\})/ );
#                my $got = $app->current_format->{unserialize}->($body);
#
#                my $error_message
#                    = qr/An error occurred during the restore process: The uploaded backup manifest file was created with Movable Type, but the schema version/;
#                like( $got->{error}{message},
#                    $error_message, 'Error message is OK.' );
#
#            },
#        },
#        {    # Not logged in.
#            path      => '/v2/restore',
#            method    => 'POST',
#            author_id => 0,
#            code      => 401,
#            error     => 'Unauthorized',
#        },
#        {    # No permissions.
#            path   => '/v2/restore',
#            method => 'POST',
#            upload => [
#                'file',
#                File::Spec->catfile(
#                    $ENV{MT_HOME},                       "t",
#                    '278-api-endpoint-backup-restore.d', 'backup.xml'
#                ),
#            ],
#            setup => sub {
#                my $file = File::Spec->catfile( $ENV{MT_HOME}, "t",
#                    '278-api-endpoint-backup-restore.d', 'backup.xml' );
#                my $schema_version = $MT::SCHEMA_VERSION;
#                system "perl -i -pe \"s{6\\.0008}{$schema_version}g\" $file";
#            },
#            is_superuser => 0,
#            restrictions => { 0 => [qw/ restore_blog /], },
#            code         => 403,
#            error =>
#                'Do not have permission to restore the requested site data.',
#        },
#
#        # restore_site - normal tests.
#        {   path   => '/v2/restore',
#            method => 'POST',
#            upload => [
#                'file',
#                File::Spec->catfile(
#                    $ENV{MT_HOME},                       "t",
#                    '278-api-endpoint-backup-restore.d', 'backup.xml'
#                ),
#            ],
#            complete => sub {
#                my ( $data, $body ) = @_;
#
#                ($body) = ( $body =~ m/(\{.+\})/ );
#                my $got = $app->current_format->{unserialize}->($body);
#
#                my $expected = +{ status => 'success', };
#
#                is_deeply( $got, $expected );
#            },
#        },

    ];
}

