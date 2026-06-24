<* Title Screen Functions Definitions (Init, Update, Draw, Unload) *>
module mygame;
import raylib6, raygui;

//----------------------------------------------------------------------------------
// Module Variables Definition
//----------------------------------------------------------------------------------
int title_frames_counter;
int title_finish_screen;

//----------------------------------------------------------------------------------
// Title Screen Functions Definition
//----------------------------------------------------------------------------------

fn void init_title_screen()
{
	title_frames_counter = 0;
	title_finish_screen  = 0;
}

fn void update_title_screen()
{
}

fn void draw_title_screen()
{
	rl::draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl::GREEN);

	RLVector2 pos = { 20, 10 };
	rl::draw_text_ex(font, "TITLE SCREEN", pos, font.base_size * 1.0f, 4.0f, rl::DARKGREEN);

	// Setup button rects (centered)
	float btn_width = 300.0f;
	float btn_height = 50.0f;
	float start_x = (SCREEN_WIDTH - btn_width) * 0.5f;

	RLRectangle play_rect = { start_x, 220.0f, btn_width, btn_height };
	RLRectangle opt_rect  = { start_x, 290.0f, btn_width, btn_height };
	RLRectangle exit_rect = { start_x, 360.0f, btn_width, btn_height };

	// 1. Play Button
	if (rg::button(play_rect, "PLAY") != 0)
	{
		rl::play_sound(fx_coin);
		transition_to_screen(GAMEPLAY);
	}

	// 2. Options Button
	if (rg::button(opt_rect, "OPTIONS") != 0)
	{
		rl::play_sound(fx_coin);
		transition_to_screen(OPTIONS);
	}

	// 3. Exit Button (Hidden on Web)
	$if !env::WASM:
		if (rg::button(exit_rect, "EXIT") != 0)
		{
			rl::play_sound(fx_coin);
			should_exit = true;
		}
	$endif
}

fn void unload_title_screen()
{
}

fn int finish_title_screen()
{
	return title_finish_screen;
}