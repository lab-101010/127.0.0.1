#!/usr/bin/env perl

#
# Create a simple XML document
#

use strict;
use warnings;
use XML::LibXML;

my $doc = XML::LibXML::Document->new('1.0', 'utf-8');

my $root = $doc->createElement("my-root-element");
$root->setAttribute('some-attr'=> 'some-value');

my %tags = (
    color => 'blue',
    metal => 'steel',
);

for my $name (keys %tags) {
    my $tag = $doc->createElement($name);
    my $value = $tags{$name};
    $tag->appendTextNode($value);
    $root->appendChild($tag);
}

$doc->setDocumentElement($root);
print $doc->toString();

# RESULTAT : 
# <?xml version="1.0" encoding="utf-8"?>
# <my-root-element some-attr="some-value">
#     <color>blue</color>
#     <metal>steel</metal>
# </my-root-element>