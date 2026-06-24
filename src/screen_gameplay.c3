<* Gameplay Screen Functions Definitions (Init, Update, Draw, Unload) *>
module mygame;
import raylib6;

//----------------------------------------------------------------------------------
// Module Variables Definition
//----------------------------------------------------------------------------------
int gameplay_frames_counter = 0;
int gameplay_finish_screen  = 0;

//----------------------------------------------------------------------------------
// Gameplay Screen Functions Definition
//----------------------------------------------------------------------------------

// Gameplay Screen Initialization logic
fn void init_gameplay_screen()
{
	// TODO: Initialize GAMEPLAY screen variables here!
	gameplay_frames_counter = 0;
	gameplay_finish_screen  = 0;
}

// Gameplay Screen Update logic
fn void update_gameplay_screen()
{
	// TODO: Update GAMEPLAY screen variables here!

	// Press enter or tap to change to ENDING screen
	if (rl::is_key_pressed(ENTER) || rl::is_gesture_detected(TAP))
	{
		gameplay_finish_screen = 1;
		rl::play_sound(fx_coin);
	}
}

// Gameplay Screen Draw logic
fn void draw_gameplay_screen()
{
	// TODO: Draw GAMEPLAY screen here!
	rl::draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl::PURPLE);
	RLVector2 pos = { 20, 10 };
	rl::draw_text_ex(font, "GAMEPLAY SCREEN", pos, font.base_size * 2.0f, 4, rl::MAROON);
	rl::draw_text_ex(font, "PRESS ENTER or TAP to go to ENDING SCREEN", { 130.0f, 220.0f }, 20.0f, 2.0f, rl::MAROON);
}

// Gameplay Screen Unload logic
fn void unload_gameplay_screen()
{
	// TODO: Unload GAMEPLAY screen variables here!
}

// Gameplay Screen should finish?
fn int finish_gameplay_screen()
{
	return gameplay_finish_screen;
}
