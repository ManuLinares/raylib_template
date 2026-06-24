<* Logo Screen Functions Definitions (Init, Update, Draw, Unload) *>
module mygame;
import raylib6;

//----------------------------------------------------------------------------------
// Module Variables Definition (local)
//----------------------------------------------------------------------------------
int   logo_frames_counter;
int   logo_finish_screen;

int   logo_position_x;
int   logo_position_y;

int   logo_letters_count;

int   logo_top_side_rec_width;
int   logo_left_side_rec_height;

int   logo_bottom_side_rec_width;
int   logo_right_side_rec_height;

int   logo_state;        // Logo animation states
float logo_alpha = 1.0f; // Useful for fading

//----------------------------------------------------------------------------------
// Logo Screen Functions Definition
//----------------------------------------------------------------------------------

// Logo Screen Initialization logic
fn void init_logo_screen()
{
	logo_finish_screen;
	logo_frames_counter;
	logo_letters_count;

	logo_position_x             = SCREEN_WIDTH  / 2 - 128;
	logo_position_y             = SCREEN_HEIGHT / 2 - 128;
	logo_top_side_rec_width     = 16;
	logo_left_side_rec_height   = 16;
	logo_bottom_side_rec_width  = 16;
	logo_right_side_rec_height  = 16;

	logo_state = 0;
	logo_alpha = 1.0f;
}

// Logo Screen Update logic
fn void update_logo_screen()
{
	switch (logo_state)
	{
		case 0:  // State 0: Top-left square corner blink logic
			logo_frames_counter++;

			if (logo_frames_counter == 80)
			{
				logo_state = 1;
				logo_frames_counter = 0;
			}
		case 1:  // State 1: Bars animation logic: top and left
			logo_top_side_rec_width    += 8;
			logo_left_side_rec_height  += 8;

			if (logo_top_side_rec_width == 256) logo_state = 2;
		case 2:  // State 2: Bars animation logic: bottom and right
			logo_bottom_side_rec_width  += 8;
			logo_right_side_rec_height  += 8;

			if (logo_bottom_side_rec_width == 256) logo_state = 3;
		case 3:  // State 3: "raylib" text-write animation logic
			logo_frames_counter++;

			if (logo_letters_count < 10)
			{
				if (logo_frames_counter / 12 > 0)  // Every 12 frames, one more letter!
				{
					logo_letters_count++;
					logo_frames_counter = 0;
				}
			}
			else  // When all letters have appeared, just fade out everything
			{
				if (logo_frames_counter > 200)
				{
					logo_alpha -= 0.02f;

					if (logo_alpha <= 0.0f)
					{
						logo_alpha = 0.0f;
						logo_finish_screen = 1; // Jump to next screen
					}
				}
			}
	}
}

// Logo Screen Draw logic
fn void draw_logo_screen()
{
	switch (logo_state)
	{
		case 0:   // Draw blinking top-left square corner
			if ((logo_frames_counter / 10) % 2 != 0) rl::draw_rectangle(logo_position_x, logo_position_y, 16, 16, rl::BLACK);
		case 1:   // Draw bars animation: top and left
			rl::draw_rectangle(logo_position_x, logo_position_y, logo_top_side_rec_width, 16, rl::BLACK);
			rl::draw_rectangle(logo_position_x, logo_position_y, 16, logo_left_side_rec_height, rl::BLACK);
		case 2:   // Draw bars animation: bottom and right
			rl::draw_rectangle(logo_position_x, logo_position_y, logo_top_side_rec_width, 16, rl::BLACK);
			rl::draw_rectangle(logo_position_x, logo_position_y, 16, logo_left_side_rec_height, rl::BLACK);

			rl::draw_rectangle(logo_position_x + 240, logo_position_y, 16, logo_right_side_rec_height, rl::BLACK);
			rl::draw_rectangle(logo_position_x, logo_position_y + 240, logo_bottom_side_rec_width, 16, rl::BLACK);
		case 3:   // Draw "raylib" text-write animation + "powered by"
			rl::draw_rectangle(logo_position_x, logo_position_y, logo_top_side_rec_width, 16, rl::BLACK.fade(logo_alpha));
			rl::draw_rectangle(logo_position_x, logo_position_y + 16, 16, logo_left_side_rec_height - 32, rl::BLACK.fade(logo_alpha));

			rl::draw_rectangle(logo_position_x + 240, logo_position_y + 16, 16, logo_right_side_rec_height - 32, rl::BLACK.fade(logo_alpha));
			rl::draw_rectangle(logo_position_x, logo_position_y + 240, logo_bottom_side_rec_width, 16, rl::BLACK.fade(logo_alpha));

			rl::draw_rectangle(SCREEN_WIDTH / 2 - 112, SCREEN_HEIGHT / 2 - 112, 224, 224, rl::RAYWHITE.fade(logo_alpha));

			rl::draw_text(rl::text_subtext("raylib", 0, logo_letters_count),
				SCREEN_WIDTH / 2 - 44, SCREEN_HEIGHT / 2 + 48, 50, rl::BLACK.fade(logo_alpha));

			if (logo_frames_counter > 20) rl::draw_text("powered by", logo_position_x, logo_position_y - 27, 20, rl::DARKGRAY.fade(logo_alpha));
	}
}

// Logo Screen Unload logic
fn void unload_logo_screen()
{
	// Unload LOGO screen variables here!
}

// Logo Screen should finish?
fn int finish_logo_screen()
{
	return logo_finish_screen;
}
