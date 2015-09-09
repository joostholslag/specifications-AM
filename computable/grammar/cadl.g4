//
// description: Antlr4 grammar for cADL sub-syntax of Archetype Definition Language (ADL2)
// author:      Thomas Beale <thomas.beale@openehr.org>
// support:     openEHR Specifications PR tracker <https://openehr.atlassian.net/projects/SPECPR/issues>
// copyright:   Copyright (c) 2015 openEHR Foundation
// license:     Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>
//

grammar cadl;
import odin_values, PCRE, base_patterns;

//
//  ======================= Parser rules ========================
//

input:
      c_complex_object
    | assertions
    ;

c_complex_object: type_id ( '[' ROOT_ID_CODE | ID_CODE ']' ) c_occurrences? ( SYM_MATCHES '{' c_attribute_def+ '}' )? ;

c_object: ( sibling_order? c_non_primitive_object ) | c_primitive_object ;

sibling_order: ( SYM_AFTER | SYM_BEFORE ) '[' ID_CODE ']' ;

c_non_primitive_object:
      c_complex_object
    | c_archetype_root
    | c_complex_object_proxy
    | archetype_slot
    ;

c_archetype_root: SYM_USE_ARCHETYPE type_id '[' ID_CODE ',' ARCHETYPE_ID ']' c_occurrences? ;

c_complex_object_proxy: SYM_USE_NODE type_id '[' ID_CODE ']' c_occurrences? ABS_PATH ;

archetype_slot:
      c_archetype_slot_head SYM_MATCHES '{' c_includes? c_excludes? '}'
    | c_archetype_slot_head
    ;

c_archetype_slot_head: c_archetype_slot_id c_occurrences? ;

c_archetype_slot_id: SYM_ALLOW_ARCHETYPE type_id '[' ID_CODE ']' SYM_CLOSED? ;

c_primitive_object:
      c_integer
    | c_real
    | c_date
    | c_time
    | c_date_time
    | c_duration
    | c_string
    | c_terminology_code
    | c_boolean
    ;

c_attribute_def:
      c_attribute
    | c_attribute_tuple
    ;

c_attribute: ( ATTRIBUTE_ID | ABS_PATH ) c_existence? c_cardinality? ( SYM_MATCHES '{' c_object+ '}' )? ;

c_attribute_tuple: '[' ATTRIBUTE_ID ( ',' ATTRIBUTE_ID )* ']' SYM_MATCHES '{' c_object_tuple ( ',' c_object_tuple )* '}' ;

c_object_tuple: '[' c_object_tuple_items ']' ;

c_object_tuple_items: '{' c_primitive_object '}' ( ',' '{' c_primitive_object '}' )* ;

c_includes: SYM_INCLUDE assertions ;
c_excludes: SYM_EXCLUDE assertions ;

assertions: assertion assertion* ;

c_existence: SYM_EXISTENCE SYM_MATCHES '{' existence '}' ;
existence: INTEGER | INTEGER '..' INTEGER ;

c_cardinality: SYM_CARDINALITY SYM_MATCHES '{' cardinality '}' ;
cardinality: multiplicity ( ordering_mod | unique_mod )* ; // max of two
ordering_mod : ';' ( SYM_ORDERED | SYM_UNORDERED ) ;
unique_mod : ';' SYM_UNIQUE ;

c_occurrences: SYM_OCCURRENCES SYM_MATCHES '{' multiplicity '}' ;

multiplicity: INTEGER | '*' | INTEGER SYM_INTERVAL_SEP ( INTEGER | '*' ) ;

c_integer: ( integer_value | integer_list | integer_interval | integer_interval_list ) ( ';' integer_value ) ;

c_real: ( real_value | real_list | real_interval | real_interval_list ) ( ';' real_value ) ;

c_date: ( DATE_CONSTRAINT_PATTERN | date_value | date_list | date_interval | date_interval_list ) ( ';' date_value ) ;

c_time: ( TIME_CONSTRAINT_PATTERN | time_value | time_list | time_interval | time_interval_list ) ( ';' time_value ) ;

c_date_time: ( DATE_TIME_CONSTRAINT_PATTERN | date_time_value | date_time_list | date_time_interval | date_time_interval_list ) ( ';' date_time_value )? ;

c_duration: (
      DURATION_CONSTRAINT_PATTERN ( '/' ( duration_interval | duration_value ))?
    | duration_value | duration_list | duration_interval | duration_interval_list ) ( ';' duration_value )?
    ;

c_string: 
    ( STRING 
    | string_list 
    | c_string 
    | '/' alternation '/'    // from PCRE grammar
    | '^' alternation '^'    // from PCRE grammar
    ) ( ';' string_value )? 
    ;

// ADL2 term types: [ac3], [ac3; at5], [at5]
c_terminology_code: '[' AC_CODE ( ';' AT_CODE ) | AT_CODE ']' ;

c_boolean: ( SYM_TRUE | SYM_FALSE | boolean_list ) ( ';' boolean_value )? ;

absolute_path : '/' ( relative_path )? ;
relative_path : path_segment ( '/' path_segment )+ ;
path_segment  : ATTRIBUTE_ID ( '[' ID_CODE ']' )? ; 


//
//  ======================= Lexical rules ========================
//

SYM_MATCHES : [Mm][Aa][Tt][Cc][Hh][Ee][Ss] | [Ii][Ss]'_'[Ii][Nn] | \u2208 ;

SYM_EXISTENCE   : [Ee][Xx][Ii][Ss][Tt][Ee][Nn][Cc][Ee] ;
SYM_OCCURRENCES : [Oo][Cc][Cc][Uu][Rr][Rr][Ee][Nn][Cc][Ee][Ss] ;
SYM_CARDINALITY : [Cc][Aa][Rr][Dd][Ii][Nn][Aa][Ll][Ii][Tt][Yy] ;
SYM_ORDERED     : [Oo][Rr][Dd][Ee][Rr][Ee][Dd] ;
SYM_UNORDERED   : [Uu][Nn][Oo][Rr][Dd][Ee][Rr][Ee][Dd] ;
SYM_UNIQUE      : [Uu][Nn][Ii][Qq][Uu][Ee] ;
SYM_USE_NODE    : [Uu][Ss][Ee][_][Nn][Oo][Dd][Ee] ;
SYM_USE_ARCHETYPE : [Uu][Ss][Ee][_][Aa][Rr][Cc][Hh][Ee][Tt][Yy][Pp][Ee] ;
SYM_ALLOW_ARCHETYPE : [Aa][Ll][Ll][Oo][Ww][_][Aa][Rr][Cc][Hh][Ee][Tt][Yy][Pp][Ee] ;
SYM_INCLUDE     : [Ii][Nn][Cc][Ll][Uu][Dd][Ee] ;
SYM_EXCLUDE     : [Ee][Xx][Cc][Ll][Uu][Dd][Ee] ;
SYM_AFTER       : [Aa][Ff][Tt][Ee][Rr] ;
SYM_BEFORE      : [Bb][Ee][Ff][Oo][Rr][Ee] ;
SYM_CLOSED      : [Cc][Ll][Oo][Ss][Ee][Dd] ;

// ---------- various ADL2 codes

ROOT_ID_CODE : 'id1' ('.1')* ;
ID_CODE      : 'id' CODE_STR ;
AT_CODE        : 'at' CODE_STR ;
AC_CODE        : 'ac' CODE_STR ;
fragment CODE_STR : ('0' | [1-9][0-9]*) ( '.' ('0' | [1-9][0-9]* ))* ;

// ---------- ISO8601-based date/time/duration constraint patterns

DATE_CONSTRAINT_PATTERN :       YEAR_PATTERN '-' MONTH_PATTERN '-' DAY_PATTERN ;
TIME_CONSTRAINT_PATTERN :       HOUR_PATTERN ':' MINUTE_PATTERN ':' SECOND_PATTERN ;
DATE_TIME_CONSTRAINT_PATTERN :  DATE_CONSTRAINT_PATTERN 'T' TIME_CONSTRAINT_PATTERN ;
DURATION_CONSTRAINT_PATTERN :   'P' [yY]?[mM]?[Ww]?[dD]? ('T' [hH]?[mM]?[sS]?)? ;

// date time pattern
fragment YEAR_PATTERN:	 		('yyy' 'y'?) | ('YYY' 'Y'?);
fragment MONTH_PATTERN:	        'mm' | 'MM' | '??' | 'XX';
fragment DAY_PATTERN:			'dd' | 'DD' | '??' | 'XX';
fragment HOUR_PATTERN:			'hh' | 'HH' | '??' | 'XX';
fragment MINUTE_PATTERN:	    'mm' | 'MM' | '??' | 'XX';
fragment SECOND_PATTERN:		'ss' | 'SS' | '??' | 'XX';
