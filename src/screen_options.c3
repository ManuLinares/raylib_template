<* Options Screen Functions Definitions (Init, Update, Draw, Unload) *>
module mygame;
import raylib6, raygui;

//----------------------------------------------------------------------------------
// Module Variables Definition
//----------------------------------------------------------------------------------
int options_frames_counter = 0;
int options_finish_screen  = 0;

//----------------------------------------------------------------------------------
// Options Screen Functions Definition
//----------------------------------------------------------------------------------

fn void init_options_screen()
{
	options_frames_counter = 0;
	options_finish_screen  = 0;
}

fn void update_options_screen()
{
}

fn void draw_options_screen()
{
	rl::draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl::DARKGRAY);

	RLVector2 pos = { 20, 10 };
	rl::draw_text_ex(font, "OPTIONS SCREEN", pos, (float)font.base_size * 1.0f, 4.0f, rl::WHITE);

	RLVector2 menu_pos = { 120.0f, 180.0f };
	rl::draw_text_ex(font, "SETTINGS MENU", menu_pos, 24.0f, 2.0f, rl::WHITE);

	// 1. Volume Slider
	RLRectangle slider_rect = { 280.0f, 240.0f, 220.0f, 30.0f };
	RLVector2 volume_label_pos = { 120.0f, 245.0f };
	rl::draw_text_ex(font, "MUSIC VOLUME", volume_label_pos, 22.0f, 2.0f, rl::LIGHTGRAY);
	rg::slider(slider_rect, null, null, &music_volume, 0.0f, 1.0f);
	rl::set_music_volume(music, music_volume);

	// 2. Fullscreen Checkbox
	RLRectangle check_rect = { 280.0f, 290.0f, 28.0f, 28.0f };
	RLVector2 fs_label_pos = { 120.0f, 295.0f };
	rl::draw_text_ex(font, "FULLSCREEN", fs_label_pos, 22.0f, 2.0f, rl::LIGHTGRAY);
	bool is_fs = rl::is_window_fullscreen();
	if (rg::check_box(check_rect, null, &is_fs) != 0)
	{
		rl::toggle_fullscreen();
	}

	// Static Info
	RLVector2 res_label_pos = { 120.0f, 340.0f };
	rl::draw_text_ex(font, "- RESOLUTION: 720x720 (VIRTUAL)", res_label_pos, 22.0f, 2.0f, rl::LIGHTGRAY);

	// 3. Back Button
	float btn_width = 300.0f;
	float btn_height = 50.0f;
	float start_x = (SCREEN_WIDTH - btn_width) * 0.5f;

	RLRectangle back_rect = { start_x, 420.0f, btn_width, btn_height };

	if (rg::button(back_rect, "BACK TO TITLE") != 0)
	{
		rl::play_sound(fx_coin);
		transition_to_screen(TITLE);
	}
}

fn void unload_options_screen()
{
}

fn int finish_options_screen()
{
	return options_finish_screen;
}