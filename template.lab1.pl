######################################### 	
#    CSCI 305 - Programming Lab #1		
#										
#  < Replace with your Name >			
#  < Replace with your Email >			
#										
#########################################

# Replace the string value of the following variable with your names.
my $name = "Travis Alpers";
my $partner = "Travis Alpers 2";

my %bigram_model;
print "CSCI 305 Lab 1 submitted by $name and $partner.\n\n";

# Checks for the argument, fail if none given
if($#ARGV != 0) {
    print STDERR "You must specify the file name as the argument.\n";
    exit 4;
}

# Opens the file and assign it to handle INFILE
open(INFILE, $ARGV[0]) or die "Cannot open $ARGV[0]: $!.\n";


# YOUR VARIABLE DEFINITIONS HERE...
my $count = 0;
# This loops through each line of the file
while($line = <INFILE>) {

	#We are regex'ing (stuff)<SEP> threee times then 
	#grabbing everything after until end of line or file in a capture group
	if ($line =~ /(.*?<SEP>){3}(.*?)(\n|$)/) {

		#get appropriate capture group, $1 contains artist
		my $rawTitle = $2;

		#we are not filtering out everything right of the stated delimiters
		if ($rawTitle =~ /(.*?)(([\[("{\/_\-\\:`+=*]|(feat))|$)/) {

			#get first capture group before delimiters
			my $fixedTitle = $1;

			#substitute given chars with the empty string
			$fixedTitle =~ s/[?!.;&$@%#|]|\168|\173//g;

			#make entire string lower case
			$fixedTitle = lc($fixedTitle);

			#filter out song titles less than 3 characters or with non english characters
			if (length($fixedTitle) < 1 | $fixedTitle =~ /[^\d\w\s']/) {
				next;
			}
			$count++;

			#split the song title into an array of words
			my @words = split(" ", $fixedTitle);

			#init counter
			my $i = 0;

			my $lastWord = @words[$i];

			#loop through song title from second word
			for ($i = 1; $i < scalar @words; $i++) {
				#check if word contains non-printable character(prevent whitespace)
				if (@words[$i] =~ /[^\w'0-9]/) {
					next;
				}

				# #filter out requested words
				if (@words[$i] =~ /^a$|^an$|^and$|^by$|^for$|^from$|^in$|^of$|^on$|^or$|^out$|^the$|^to$|^with$/) {
					next;
				}

				#this is our build segment, check if first word exists in bigram
				if (exists $bigram_model{$lastWord}) {
					#first word exists, check second in second hash
					if (exists $bigram_model{$lastWord}{@words[$i]}) {

						#second word exists, increment counter
						$bigram_model{$lastWord}{@words[$i]} += 1;
					} else {	

						#second word doesn't exist, init counter to 1
						$bigram_model{$lastWord}{@words[$i]} = 1;
					}
				} else {
					#first word doesn't exist, init first word to hash containing second word with count = 1
					$bigram_model{$lastWord} = {(@words[$i] => 1)};
				}
				#set previous word to current word for next iteration
				$lastWord = @words[$i];
			}
		}
	}
}

# Close the file handle
close INFILE; 

# At this point (hopefully) you will have finished processing the song 
# title file and have populated your data structure of bigram counts.
print "File parsed. Bigram model built. Count: ".scalar %bigram_model."\n\n";

$input = "e";

while ($input ne "q"){
	# User control loop
	print "Enter a word [Enter 'q' to quit]: ";

	#wait for user input, grab user console input
	$input = <STDIN>;

	#newline for readability
	print "\n";	

	#chomp trailing whitespace characters
	chomp($input);

	#split user input for extra functionality
	#usage: <word> - Get song title  <word> a - Get second word frequencies and total count
	@words = split(" ", $input);

	#make input lower case
	$input = lc(@words[0]);

	#check for 'a' argument, for extra functionality
	if (@words[1] =~ /a/) {
		print_all_words($input);
	} else {
		#else print input word
		print $input." ";
		#init nextWord
		my $nextWord = $input;

		for (my $i = 0; $i < 20; $i++) {
			#set nextWord to most common following word of current nextWord
			$nextWord = mcw($nextWord);


			#print
			print $nextWord." ";
		}
		#newline for readability
		print "\n";
	}
}


# Optimized find largest using idea from http://stackoverflow.com/a/2887547
# Subroutine mcw($string) takes in a string used as a key
# on the bigram_model and returns the most used word to follow
# it from the songs processed.
sub mcw {
	#get passed variable
	my $input = shift;

	#get key array
	my ($key, @keys) = keys %{$bigram_model{$input}};

	#get value array
	my ($big, @vals) = values %{$bigram_model{$input}};

	#iterate over keys by ref
	for (0 .. $#keys) {
		#if current value is bigger than current big, get new key and set big
		if ($vals[$_] > $big) {
			$big = $vals[$_];
			$key = $keys[$_];
		}
		#if current value is equal to big, do rand() to pick key per instructions
		if ($vals[$_] == $big) {
			my $test = int(rand(2));
			# print "Rand: $test\n";
			$key = $test ? $keys[$_] : $key;
		}
	}
	return $key;

}

#helper function for easy lab question answers
#prints all associated words and their counts
sub print_all_words {
	#get subrouting argument
	my $input = shift;

	#init counter
	my $count_unique = 0;

	#iterate over each key after sorting by value descending
	foreach my $key (sort { ${$bigram_model{$input}}{$a} <=> ${$bigram_model{$input}}{$b}} keys %{$bigram_model{$input}}) {
		#print key: count
		print $key.": ".$bigram_model{$input}{$key}."\n";

		#increment unique word counter
		$count_unique++;
	}

	#print unique words
	print "Unique Words: ".$count_unique."\n";
}
