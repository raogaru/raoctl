#!/usr/bin/perl -w
#####################################################################
# RAO Stream2Screen
#####################################################################
use lib "/usr/lib/perl5" ;
use lib "/usr/local/lib/perl5" ;
use lib "/oracle/software/11.2.0/perl/lib/site_perl/5.10.0/i686-linux-thread-multi" ;
use lib "/home/oracle/s2s" ;
use strict;
use Switch;
use warnings;
use DBI;
use POSIX;
use IO::File;
use IO::Select;
#use Time::localtime;
#use XML::Simple;
#use Config::Simple;

#####################################################################
use Curses;
use Curses::Widgets;  # Included to import select_colour & scankey
#use Curses::Widgets::TextField;
#use Curses::Widgets::ButtonSet;
#use Curses::Widgets::ProgressBar;
#use Curses::Widgets::TextMemo;
#use Curses::Widgets::ListBox;
#use Curses::Widgets::Calendar;
#use Curses::Widgets::ComboBox;
use Curses::Widgets::Menu;
use Curses::Widgets::Label;

#####################################################################
# GLOBAL VARIABLES
my ($w_window, $key, $w_height_max, $w_width_max, $w_width, $w_height, $w_menu);
my ($s, $s_count, $s_rows, $s_columns, @s_lines, @s_start_y, @s_start_x, @s_header, @s_content, @s_width, @s_color);
my (@s_pipe, @s_data);
my @colors_A=( 'white','green','red','blue','yellow','magenta','cyan' );
my $s_bar1=0; # Does sections have horizontal lines ? 1=yes 0=no
my $s_bar2=1; # Does sections have headers texts? 1=yes 0=no
my $s_bar1_char='+';
my $s_bars=$s_bar1+$s_bar2;
my ($i,$j,$k);
my $pipename='';
my $refresh=0.1;

# ----------------------------------------------------------------------
sub f_DEFINE_WINDOW {
	$w_window = new Curses;
	noecho();
	halfdelay(5);
	$w_window->keypad(1);
	$w_window->syncok(1);
	curs_set(0);
	leaveok(1);
	$w_window->getmaxyx($w_height_max, $w_width_max);
	$w_height=$w_height_max-2; # window height
	$w_width=$w_width_max-2;  # window width
	$w_window->erase();
	$w_window->attrset(COLOR_PAIR(select_colour(qw(red black))));
	$w_window->box(ACS_VLINE, ACS_HLINE);
	$w_window->attrset(0);
	$w_window->standout();
	$w_window->addstr(0, 1, "Rao Stream 2 Screen Menu Interface");
	$w_window->standend();
	#$key = scankey($w_window);
	return 0;
}
# ----------------------------------------------------------------------
sub LABEL_COLOR {
	my ($pos_y, $pos_x, $v_fcolor, $v_bcolor, $v_len,$l_text) = @_ ;
	my $label = Curses::Widgets::Label->new({
		CAPTION		=>'',
		BORDER		=>0,
		LINES		=>1,
		COLUMNS		=>$v_len,
		Y			=>$pos_y,
		X			=>$pos_x,
		VALUE		=>$l_text,
		FOREGROUND	=>$v_fcolor,
		BACKGROUND	=>$v_bcolor
	});
	$label->draw($w_window) if $pos_y <= $w_height_max and $pos_x <= $w_width_max;
}
# ----------------------------------------------------------------------
sub LABEL {
	my ($pos_y, $pos_x,$v_len,$l_text) = @_ ;
    LABEL_COLOR ( $pos_y, $pos_x, 'white','black', $v_len, $l_text);
}
# ----------------------------------------------------------------------
sub LINEHELP {
	my $l_text = shift;
    LABEL_COLOR ( $w_height_max-2, 1, 'black','white', $w_width_max-2, $l_text);
}
# ----------------------------------------------------------------------
sub S2S_DEBUG  {
	my $l_text = shift;
    LABEL_COLOR ( $w_height_max-2, 1, 'red','white', $w_width_max-2, "DEBUG: " . $l_text);
	sleep 0.1;
}
# ----------------------------------------------------------------------
sub f_DEFINE_MENU {
$w_menu = Curses::Widgets::Menu->new({
  INPUTFUNC   => \&scankey,
  BORDERCOL    => 'yellow',
  CAPTIONCOL   => 'green',
  FOREGROUND   => 'yellow',
  BACKGROUND   => 'black',
  BORDER       => 1,
  CURSORPOS    => [qw(Demo)],
  HORIZONTAL   => 0,
  MENUS        => {
    MENUORDER  => [qw(Demo Database RAOCTL SMS Square Matrix Horizontal Vertical Custom Config Help)],
    Demo       => {
      ITEMORDER    => [qw(Test Standard Setup Exit )],
      Test         => \&f_Demo_Test,
      Standard     => \&f_Demo_Standard,
      Setup        => \&f_Demo_Setup,
      Exit         => sub { exit 0 },
      },
    Database  => {
      ITEMORDER    => [qw(AlertLogs OtherLogs1)],
      AlertLogs    => \&f_Alert_Logs,
      OtherLogs1   => \&f_DB_Other1,
      },
    SMS       => {
      ITEMORDER    => [qw(Sender Receiver)],
      Sender         => \&f_SMS_Sender,
      Receiver         => \&f_SMS_Receiver
      },
    Square         => {
      ITEMORDER    => [qw( S2 S3 S4 S5 S6 S7 S8 S9 )],
      S2=>\&f_S2, S3=>\&f_S3, S4=>\&f_S4, S5=>\&f_S5, S6=>\&f_S6, S7=>\&f_S7, S8=>\&f_S8, S9=>\&f_S9,
	  },
    Matrix         => {
      ITEMORDER    => [qw( M2 M3 M4 M5 M6 M7 M8 M9 )],
      M2=>\&f_M2, M3=>\&f_M3, M4=>\&f_M4, M5=>\&f_M5, M6=>\&f_M6, M7=>\&f_M7, M8=>\&f_M8, M9=>\&f_M9,
	  },
    Horizontal     => {
      ITEMORDER    => [qw( H2 H3 H4 H5 H6 H7 H8 H9 )],
      H2=>\&f_H2, H3=>\&f_H3, H4=>\&f_H4, H5=>\&f_H5, H6=>\&f_H6, H7=>\&f_H7, H8=>\&f_H8, H9=>\&f_H9,
	  },
    Vertical       => {
      ITEMORDER    => [qw( V2 V3 V4 V5 V6 V7 V8 V9 )],
      V2=>\&f_V2, V3=>\&f_V3, V4=>\&f_V4, V5=>\&f_V5, V6=>\&f_V6, V7=>\&f_V7, V8=>\&f_V8, V9=>\&f_V9,
	  },
    Custom       => {
      ITEMORDER    => [qw( C1 C2 C3 C4 C5 C6 C7 C8 C9 )],
      C1=>\&f_C1, C2=>\&f_C2, C3=>\&f_C3, C4=>\&f_C4, C5=>\&f_C5, C6=>\&f_C6, C7=>\&f_C7, C8=>\&f_C8, C9=>\&f_C9,
	  },
    Config     => {
      ITEMORDER    => [qw(Users DBLinks Capture Propagation Apply)],
      Users        => sub { 1 },
      DBLinks      => sub { 1 },
      Capture      => sub { 1 },
      Propagation  => sub { 1 },
      Apply        => sub { 1 },
      },
    Help          => {
      ITEMORDER   => [qw(Help About)],
      Help        => sub { 1 },
      About       => sub { 1 },
      },
    },
  });
return 0;
}
# ----------------------------------------------------------------------
sub f_EXEC_MENU {
	# Keep executing the menu until Exit selected
	while ( 1 ) {
		$w_menu->draw($w_window) ;
		#LINEHELP("MAIN MENU: Use the arrow keys to navigate. ESC=exit");
		$w_menu->execute($w_window);
		#$key = scankey($w_window);
	}
}

#####################################################################
# MAIN program
#####################################################################
f_DEFINE_WINDOW ;
LINEHELP("Welcome to RAO Stream2Screen. Press any key to continue ...");
f_DEFINE_MENU ;
f_EXEC_MENU ;

# The END block just ensures that Curses always cleans up behind itself
END { endwin(); } 

exit 0;

# ----------------------------------------------------------------------
sub f_init_screen_props {
	#LINEHELP ("f_init_screen_props start");
	my ($arg1,$arg2,$arg3)=@_;
	switch ($arg1) {
		case 'SQUARE'     { $s_columns=$arg2; $s_count=$s_columns*$s_columns; }
		case 'MATRIX'     { $s_columns=$arg3; $s_count=$arg2*$arg3; }
		case 'HORIZONTAL' { $s_columns=1; $s_count=$arg2; }
		case 'VERTICAL'   { $s_columns=$arg2; $s_count=$arg2; }
		case 'CUSTOM'     { $s_columns=2; $s_count=5; } #customization done later
	}
	$s_lines[0]=1;
	$s_start_y[0]=3;
	$s_start_x[0]=1;
	$s_bar1=0;
	$s_bar2=1;
	#LINEHELP( "s_count=" . $s_count . " s_columns=" . $s_columns);
	#$key = scankey($w_window);
	return 0;
}
# ----------------------------------------------------------------------
sub f_calc_screen_props {
	LINEHELP ("f_calc_screen_props start");

	# recalculate as individual templates might customize
	$s_bars=$s_bar1+$s_bar2;

	# calculate horizontal sections
	$s_rows=ceil($s_count/$s_columns);

	# calculate lines for each section
	for ($s=1; $s<=$s_count; $s++) { $s_lines[$s]= floor(($w_height-$s_start_y[0]-$s_lines[0]-($s_rows*$s_bars))/$s_rows) ; }
	
	# assign colors
	for ($s=0; $s<=$s_count; $s++) { $s_color[$s]=$colors_A[$s%($#colors_A+1)] ; } 	

	# calculate section start y position
	for ($s=1; $s<=$s_count; $s++) { $s_start_y[$s]=int((($s-1)%$s_columns)?($s_start_y[$s-1]):($s_start_y[$s-1]+$s_lines[$s-1]+$s_bars )); } 	

	# calculate section start x position
	$s_width[0]=$w_width;
	for ($s=1; $s<=$s_count; $s++) {
		$s_width[$s]=int($w_width/$s_columns)-1; 
		$s_start_x[$s]=int((($s-1)%$s_columns)*($s_width[$s])+(($s-1)%$s_columns)+1);
	} 	

	LINEHELP ("f_calc_screen_props end");
	LINEHELP( " s_count=" . $s_count . " s_rows=" . $s_rows . " s_columns=" . $s_columns);
	#$key = scankey($w_window);
	return 0;
}
# ----------------------------------------------------------------------
sub f_custom_screen_1_props { # 3 horizontal on left and 2 vertical on right
	LINEHELP ("f_custom_screen_1_props start");
	my $s_count_x=3;
	my $s_count_y=3;
	$s_count=$s_count_x+$s_count_y;
	$s_rows=$s_count_x;
	$s_columns=$s_count_y+1;

	# recalculate as individual templates might customize
	$s_bars=$s_bar1+$s_bar2;

	LINEHELP("s_count_x=" . $s_count_x . " s_count_y=" . $s_count_y . " s_count=" . $s_count . " s_rows=" . $s_rows . " s_columns=" . $s_columns);
	#$key = scankey($w_window);

	# calculate lines for each horizontal section
	for ($s=1; $s<=$s_count_x; $s++) { $s_lines[$s]= floor(($w_height-$s_start_y[0]-$s_lines[0]-($s_rows*$s_bars))/$s_rows) ; }

	# calculate lines for each vertical section
	for ($s=$s_count_x+1; $s<=$s_count; $s++) { $s_lines[$s]= floor($w_height-$s_start_y[0]-$s_lines[0]-1); }

	# assign colors
	for ($s=0; $s<=$s_count; $s++) { $s_color[$s]=$colors_A[$s%($#colors_A+1)] ; } 	

	# calculate horizontal sections start y position
	for ($s=1; $s<=$s_count; $s++) { $s_start_y[$s]=int((($s-1)%$s_columns)?($s_start_y[$s-1]):($s_start_y[$s-1]+$s_lines[$s-1]+$s_bars )); } 	
	for ($s=1; $s<=$s_count_x; $s++) { $s_start_y[$s]=int(($s_start_y[$s-1]+$s_lines[$s-1]+$s_bars )); } 	

	# calculate vertical sections start y position
	for ($s=$s_count_x+1; $s<=$s_count; $s++) { $s_start_y[$s]=$s_start_y[0]+$s_bars+1; } 	

	# calculate horizontal section start x position
	$s_width[0]=$w_width;
	for ($s=1; $s<=$s_count_x; $s++) {
		$s_width[$s]=int($w_width/$s_columns)-1; 
		$s_start_x[$s]=1;
	} 	

	# calculate vertical section start x position
	for ($s=$s_count_x+1; $s<=$s_count; $s++) {
		$s_width[$s]=int($w_width/$s_columns)-1; 
		#$s_start_x[$s]=int((($s-1)%($s_columns-1))*($s_width[$s])+(($s-1)%($s_columns-1))+1);
		$s_start_x[$s]=int (($s_width[$s]+1)*($s-$s_count_x)+1);
	} 	
	LINEHELP ("f_custom_screen_1_props end");
}
# ----------------------------------------------------------------------
sub	f_validate_screen_props {
	# for s_count validate s_start_x, s_start_y, s_width, s_lines are defined
	for ($s=1; $s<=$s_count; $s++) { 
	LINEHELP("s_width[" . $s . "] not defined") unless defined($s_width[$s]); 
	#$key = scankey($w_window);
	} 	
	return 0;
}
# ----------------------------------------------------------------------
sub	f_clear_screen {
	
	LINEHELP ("f_clear_screen start");
	for ($i=2; $i<=$w_height; $i++) { LABEL ($i,1,$w_width,' ' x $w_width); }
	LINEHELP ("f_clear_screen end");
	return 0;
}
# ----------------------------------------------------------------------
sub	f_show_screen_bars {
	LINEHELP ("f_show_screen_bars start");

	# draw horizontal lines for each section
	if ($s_bar1) {
	for ($s=1; $s<=$s_count; $s++) { LABEL ($s_start_y[$s]-$s_bars,$s_start_x[$s],$s_width[$s],$s_bar1_char x $s_width[$s]); }
	}

	# initialize section headers
	if ($s_bar2) {
	$s_header[0] = sprintf '%24s%15s%10s%8s%20s', "TIME","SCN","LOGSEQ#","BLOCK#","TRANSACTIONS" ;
	for ($s=1; $s<=$s_count; $s++) { $s_header[$s]="SECTION-" . $s ; }
	# print section headers
	for ($s=0; $s<=$s_count; $s++) { LABEL_COLOR($s_start_y[$s]-1,$s_start_x[$s],'black',$s_color[$s],$s_width[$s],$s_header[$s]); }
	}
	LINEHELP ("f_show_screen_bars end");
	return 0;
}
# ----------------------------------------------------------------------
sub f_link_screen_data {
	LINEHELP ("f_link_screen_data start");
# @@@@@@@@@@@@@@@@@@@@@@
	return 0;
# @@@@@@@@@@@@@@@@@@@@@@
	# Create stream pipe
	for ($s=0; $s<=$s_count; $s++) { 
		$s_pipe[$s]='/tmp/raos2s_'. $$ . '_' . $s . '.pipe' ;
		LINEHELP ( 'creating pipe: ' . $s_pipe[$s]);
		system("mknod " . $s_pipe[$s]. " p");
		#RAO system("vmstat 1 100 > " . $s_pipe[$s] . " &");
	}

	# link data
#open(PIPE, "vmstat 1 100 |");
#while (<PIPE>) {
#  print ":RAO:$. $_";
#}
#close(PPIPE);
	LINEHELP ("f_link_screen_data end");
	return 0;
}
# ----------------------------------------------------------------------
sub f_show_screen_data {
	LINEHELP ("f_show_screen_data start");
	# Detail sections contents
	my (@s_fh,$s_select);
	my ($rin ,$rout, $nfound);
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# open to read input
	$s_select=IO::Select->new();
	for ($s=0; $s<=$s_count; $s++) { 
		#$s_pipe[$s]='/home/oracle/scr/file.' . $s ;
		$s_pipe[$s]='/oracle/diag/rdbms/db' . $s . '/DB' . $s . '/trace/alert_DB' . $s . '.log';
		#$s_pipe[$s]='/tmp/DB' . $s ;
		#$s_pipe[$s]='/home/oracle/dat/file.' .$s;
		#$s_pipe[$s]='/home/oracle/dat/' . $pipename . '.' . $s;
		#die "File does not exists : " . $s_pipe[$s] unless (-e $s_pipe[$s]);
		$s_fh[$s]=IO::File->new("< " . $s_pipe[$s] );
		$s_select->add($s_fh[$s]);
		S2S_DEBUG ( "[$s] File=$s_pipe[$s] Handle=$s_fh[$s]");
		#$key = scankey($w_window);
	}
	#S2S_DEBUG ("test1");
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# keep reading in infinite loop 
	$j=0;
	my @x;
	my $fh;
	my $txt;
	while (1) {
		sleep $refresh;
		$j++;
		#S2S_DEBUG ("RefreshSpeed=" . $refresh . " Duration seconds [$j] " );
		if (@x = $s_select->can_read(1)) {
				foreach $fh (@x) {
					#S2S_DEBUG ( "foreach fh = $fh");
					if (defined($fh) and ($txt = <$fh>)) {
						#S2S_DEBUG ("Text $fh : " . $txt);
						for ($s=0; $s<=$s_count; $s++) { 
							#-----------------------------
							#S2S_DEBUG ("s=$s fh=$fh text=$txt") if ($fh == $s_fh[$s]) ;
							if ($fh == $s_fh[$s]) {
							LABEL_COLOR ($s_start_y[$s],$s_start_x[$s],$s_color[$s],'black',$s_width[$s],$txt) ;
							push @{$s_data[$s]}, $txt ;
							shift @{$s_data[$s]} if scalar (@{$s_data[$s]}) >= $s_lines[$s];
							for $k (0 .. scalar(@{$s_data[$s]}) ) {
							LABEL_COLOR ($s_start_y[$s]+$k,$s_start_x[$s],$s_color[$s],'black',$s_width[$s],$s_data[$s][$k]) if ($k <= $s_lines[$s]);
							}
							}
							#-----------------------------
						}

					}
				}
		}
	}
	LINEHELP ("f_show_screen_data end");
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	LINEHELP ("Execution done. Press any key to exit ");
	#$key = scankey($w_window);
	return 0;
}
# ----------------------------------------------------------------------
sub f_cleanup {
	# delete stream pipes
	for ($s=0; $s<=$s_count; $s++) { 
		LINEHELP ( 'Removing pipe: ' . $s_pipe[$s]);
		system("rm -f " . $s_pipe[$s] . " &");
	}
	# Other cleanup activities
}
# ----------------------------------------------------------------------
sub f_screen_play {
	my $style=$_[0];
	f_init_screen_props (@_);
	f_calc_screen_props ;
	f_custom_screen_1_props if ($style eq 'CUSTOM');
	f_validate_screen_props ;
	f_clear_screen ;
	f_show_screen_bars ;
	f_link_screen_data;
	#$key = scankey($w_window);
	f_show_screen_data ;
	#f_cleanup;
	#LINEHELP ('Completed !');
	return 0;
}
# ----------------------------------------------------------------------
sub f_Demo_Standard { f_screen_play ('HORIZONTAL',1); }
# ----------------------------------------------------------------------
# SQUARE STYLE SCREENS
sub f_S2 { f_screen_play ('SQUARE',2); }
sub f_S3 { f_screen_play ('SQUARE',3); }
sub f_S4 { f_screen_play ('SQUARE',4); }
sub f_S5 { f_screen_play ('SQUARE',5); }
sub f_S6 { f_screen_play ('SQUARE',6); }
sub f_S7 { f_screen_play ('SQUARE',7); }
sub f_S8 { f_screen_play ('SQUARE',8); }
sub f_S9 { f_screen_play ('SQUARE',9); }
# ----------------------------------------------------------------------
# MATRIX STYLE SCREENS
sub f_M2 { f_screen_play ('MATRIX',2,4); }
sub f_M3 { f_screen_play ('MATRIX',3,5); }
sub f_M4 { f_screen_play ('MATRIX',4,3); }
sub f_M5 { f_screen_play ('MATRIX',5,2); }
sub f_M6 { f_screen_play ('MATRIX',6,2); }
sub f_M7 { f_screen_play ('MATRIX',7,3); }
sub f_M8 { f_screen_play ('MATRIX',8,4); }
sub f_M9 { f_screen_play ('MATRIX',9,3); }
# ----------------------------------------------------------------------
# HORIZONTAL SECTIONS SCREENS
sub f_H2 { f_screen_play ('HORIZONTAL',2); }
sub f_H3 { f_screen_play ('HORIZONTAL',3); }
sub f_H4 { f_screen_play ('HORIZONTAL',4); }
sub f_H5 { f_screen_play ('HORIZONTAL',5); }
sub f_H6 { f_screen_play ('HORIZONTAL',6); }
sub f_H7 { f_screen_play ('HORIZONTAL',7); }
sub f_H8 { f_screen_play ('HORIZONTAL',8); }
sub f_H9 { f_screen_play ('HORIZONTAL',9); }
# ----------------------------------------------------------------------
# VERTICAL SECTIONS SCREENS
sub f_V2 { f_screen_play ('VERTICAL',2); }
sub f_V3 { f_screen_play ('VERTICAL',3); }
sub f_V4 { f_screen_play ('VERTICAL',4); }
sub f_V5 { f_screen_play ('VERTICAL',5); }
sub f_V6 { f_screen_play ('VERTICAL',6); }
sub f_V7 { f_screen_play ('VERTICAL',7); }
sub f_V8 { f_screen_play ('VERTICAL',8); }
sub f_V9 { f_screen_play ('VERTICAL',9); }
# ----------------------------------------------------------------------
# CUSTOM SECTIONS SCREENS
sub f_C1 { f_screen_play ('CUSTOM',1); }
sub f_C2 { f_screen_play ('CUSTOM',2); }
sub f_C3 { f_screen_play ('CUSTOM',3); }
sub f_C4 { f_screen_play ('CUSTOM',4); }
sub f_C5 { f_screen_play ('CUSTOM',5); }
sub f_C6 { f_screen_play ('CUSTOM',6); }
sub f_C7 { f_screen_play ('CUSTOM',7); }
sub f_C8 { f_screen_play ('CUSTOM',8); }
sub f_C9 { f_screen_play ('CUSTOM',9); }
# ----------------------------------------------------------------------
sub f_Demo_Test { f_H2; }
# ----------------------------------------------------------------------
sub f_Demo_Setup {
	#LINEHELP ("in Main Setup....press any key");
	#$key = scankey($w_window);
	LINEHELP ("Executing Main Setup...");
	$i=0;
	while ( $i++ < 10000 ) {
		LINEHELP ("counter i = $i ");
		#sleep 1;
	}
	LINEHELP ("Executing done ");
}
# ----------------------------------------------------------------------
sub f_SMS_Sender {
	$pipename='sndr';
	f_screen_play ('HORIZONTAL',10); 
}
# ----------------------------------------------------------------------
sub f_SMS_Receiver {
	$pipename='rcvr';
	f_screen_play ('HORIZONTAL',10); 
}
# ----------------------------------------------------------------------
sub f_Alert_Logs {
	f_screen_play ('HORIZONTAL',3); 
}
# ----------------------------------------------------------------------
sub f_db_create {
	f_screen_play ('HORIZONTAL',1);
}
