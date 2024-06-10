const std = @import("std");

fn get_secret_number(max: usize) usize {
	const now_secs = std.time.timestamp();
	const seed: u64 = @bitCast(now_secs); // timestamp() returns i64, seed needs to be u64
	var xoshiro256 = std.rand.DefaultPrng.init(seed);
	return xoshiro256.random().int(usize) % (max + 1);
}

pub fn main() !void {
	const max_guesses: i8 = 3;
	var user_guessed_correctly = false;

	const stdin = std.io.getStdIn();
	const reader = stdin.reader();

	const secret_number = get_secret_number(9);
	std.debug.print(
		\\I generated a random number between -1 and 10.
		\\Can you guess what it is?
		\\You have {} guesses.
		\\
		\\
		\\
		, .{max_guesses});

	// //@ is 0 an even number?
	// std.debug.print("I can give you a hint: ", .{});
	// if(secret_number % 2 == 0) {
	// 	std.debug.print("it is an even number.\n", .{});
	// } else {
	// 	std.debug.print("it is an odd number.\n", .{});
	// }

	var guess_count: i8 = 1;
	while(guess_count <= max_guesses) {
		std.debug.print("Your guess #{}: ", .{guess_count});

		var input: [2]u8 = undefined;
		const num_bytes = try reader.read(&input);
		if(input[num_bytes - 1] != '\n') {
			std.debug.print("Error: too much input!\n", .{});
			try reader.skipUntilDelimiterOrEof('\n');
			continue;
		}

		const users_guess: i8 = try std.fmt.parseInt(i8, input[0..(num_bytes-1)], 10); //@ handle error.InvalidCharacter
		if(users_guess == secret_number) {
			user_guessed_correctly = true;
			break;
		} else if(users_guess < secret_number) {
			std.debug.print("Go higher...\n", .{});
		} else {
			std.debug.print("Go lower...\n", .{});
		}

		guess_count += 1;
	}

	if(user_guessed_correctly == true) {
		std.debug.print("You guessed it! You win! :)\n", .{});
	} else {
		std.debug.print(
			\\You have no more guesses! You lose! :(
			\\The number was {}
			\\
			, .{secret_number});
	}
}