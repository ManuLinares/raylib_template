// Ending Screen Functions Definitions (Init, Update, Draw, Unload)
module mygame;
import raylib6;

//----------------------------------------------------------------------------------
// Module Variables Definition
//----------------------------------------------------------------------------------
int ending_frames_counter = 0;
int ending_finish_screen  = 0;

//----------------------------------------------------------------------------------
// Ending Screen Functions Definition
//----------------------------------------------------------------------------------

// Ending Screen Initialization logic
fn void init_ending_screen()
{
	// TODO: Initialize ENDING screen variables here!
	ending_frames_counter = 0;
	ending_finish_screen  = 0;
}

// Ending Screen Update logic
fn void update_ending_screen()
{
	// TODO: Update ENDING screen variables here!

	// Press enter or tap to return to TITLE screen
	if (rl::is_key_pressed(ENTER) || rl::is_gesture_detected(TAP))
	{
		ending_finish_screen = 1;
		rl::play_sound(fx_coin);
	}
}

// Ending Screen Draw logic
fn void draw_ending_screen()
{
	// TODO: Draw ENDING screen here!
	rl::draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl::BLUE);
	RLVector2 pos = { 20, 10 };
	rl::draw_text_ex(font, "ENDING SCREEN", pos, font.base_size * 3.0f, 4, rl::DARKBLUE);
	rl::draw_text_ex(font, "PRESS ENTER or TAP to RETURN to TITLE SCREEN", { 120.0f, 220.0f }, 20.0f, 2.0f, rl::DARKBLUE);
}

// Ending Screen Unload logic
fn void unload_ending_screen()
{
	// TODO: Unload ENDING screen variables here!
}

// Ending Screen should finish?
fn int finish_ending_screen()
{
	return ending_finish_screen;
}
