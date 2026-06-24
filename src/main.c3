<* raylib game template - C3 *>
module mygame;
import std, raylib6, raygui;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
constdef GameScreen : inline int
{
	UNKNOWN       = -1,
	CLICK_TO_PLAY = 0, // Added to prevent autoplay blocks on Web
	LOGO          = 1,
	TITLE         = 2,
	OPTIONS       = 3,
	GAMEPLAY      = 4,
	ENDING        = 5,
}

//----------------------------------------------------------------------------------
// Shared Variables Definition (global)
//----------------------------------------------------------------------------------
bool       should_exit = false;
GameScreen current_screen = LOGO;
RLFont     font;
RLMusic    music;
RLSound    fx_coin;
RLRenderTexture2D target_canvas; // Virtual rendering target
float      music_volume = 1.0f; // Global volume variable

//----------------------------------------------------------------------------------
// Module-local Variables
//----------------------------------------------------------------------------------
const int SCREEN_WIDTH  = 720;
const int SCREEN_HEIGHT = 720;
const int TARGET_FPS    = 60;

// Screen transition state
float      trans_alpha       = 0.0f;
bool       on_transition     = false;
bool       trans_fade_out    = false;
int        trans_from_screen = -1;
GameScreen trans_to_screen   = UNKNOWN;

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------

// WASM entry point shim
alias Em_callback_func = fn void();
extern fn void emscripten_set_main_loop(Em_callback_func func, int fps, int simulate_infinite_loop);


//----------------------------------------------------------------------------------
// Program main entry point
//----------------------------------------------------------------------------------
fn int main(String[] args) @winmain
{
	// Initialization
	//---------------------------------------------------------
	$if !env::WASM:
		rl::set_config_flags(WINDOW_RESIZABLE);
	$endif

	rl::init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib game template");

	rl::init_audio_device();

	// Load virtual canvas
	target_canvas = rl::load_render_texture(SCREEN_WIDTH, SCREEN_HEIGHT);
	target_canvas.texture.set_filter(RLTextureFilter.POINT);

	// Load global data (assets that must be available in all screens, i.e. font/sounds/music)
	//font    = rl::get_font_default(); // you can use the default raylib font, or
	font = rl::load_font_ex("resources/fonts/smallest_pixel-7.ttf", 32, null, 0);
	font.texture.set_filter(RLTextureFilter.POINT);
	rg::set_font(font); // set raygui to use this font
	rg::set_style(RGGuiControl.DEFAULT, RGGuiProperty.TEXT_SIZE, 32);

	music   = rl::load_music_stream("resources/sound/music_vorbis.ogg");
	fx_coin = rl::load_sound("resources/sound/coin.wav");

	rl::set_music_volume(music, 1.0f);

	// Setup and init first screen
	$if env::WASM:
		current_screen = CLICK_TO_PLAY;
	$else
		rl::play_music_stream(music);
		current_screen = LOGO;
		init_logo_screen();
	$endif

	$if env::WASM:
		emscripten_set_main_loop(&update_draw_frame, TARGET_FPS, 1);
	$else
		rl::set_target_fps(TARGET_FPS);

		// Main game loop
		while (!rl::window_should_close() && !should_exit)
		{
			update_draw_frame();
		}
	$endif

	// De-Initialization
	switch (current_screen)
	{
		case LOGO:     unload_logo_screen();
		case TITLE:    unload_title_screen();
		case OPTIONS:  unload_options_screen();
		case GAMEPLAY: unload_gameplay_screen();
		case ENDING:   unload_ending_screen();
	}

	// Unload global data loaded
	rl::unload_render_texture(target_canvas);
	rl::unload_font(font);
	rl::unload_music_stream(music);
	rl::unload_sound(fx_coin);

	rl::close_audio_device();
	rl::close_window();

	return 0;
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Change to next screen, no transition effect
fn void change_to_screen(GameScreen screen)
{
	// Unload current screen
	switch (current_screen)
	{
		case LOGO:     unload_logo_screen();
		case TITLE:    unload_title_screen();
		case OPTIONS:  unload_options_screen();
		case GAMEPLAY: unload_gameplay_screen();
		case ENDING:   unload_ending_screen();
		default:       break;
	}

	// Init next screen
	switch (screen)
	{
		case LOGO:     init_logo_screen();
		case TITLE:    init_title_screen();
		case OPTIONS:  init_options_screen();
		case GAMEPLAY: init_gameplay_screen();
		case ENDING:   init_ending_screen();
		default:       break;
	}

	current_screen = screen;
}

// Request transition to next screen
fn void transition_to_screen(GameScreen screen)
{
	on_transition     = true;
	trans_fade_out    = false;
	trans_from_screen = current_screen;
	trans_to_screen   = screen;
	trans_alpha       = 0.0f;
}

// Update transition effect (fade-in, fade-out)
fn void update_transition()
{
	if (!trans_fade_out)
	{
		trans_alpha += 0.05f;

		// NOTE: Due to float internal representation, condition jumps on 1.0f instead of 1.05f
		// For that reason we compare against 1.01f, to avoid last frame loading stop
		if (trans_alpha > 1.01f)
		{
			trans_alpha = 1.0f;

			// Unload current screen
			switch ((GameScreen)trans_from_screen)
			{
				case LOGO:     unload_logo_screen();
				case TITLE:    unload_title_screen();
				case OPTIONS:  unload_options_screen();
				case GAMEPLAY: unload_gameplay_screen();
				case ENDING:   unload_ending_screen();
				default:       break;
			}

			// Load next screen
			switch (trans_to_screen)
			{
				case LOGO:     init_logo_screen();
				case TITLE:    init_title_screen();
				case OPTIONS:  init_options_screen();
				case GAMEPLAY: init_gameplay_screen();
				case ENDING:   init_ending_screen();
				default:       break;
			}

			current_screen = trans_to_screen;

			// Activate fade out effect to next loaded screen
			trans_fade_out = true;
		}
	}
	else // Transition fade out logic
	{
		trans_alpha -= 0.02f;

		if (trans_alpha < -0.01f)
		{
			trans_alpha       = 0.0f;
			trans_fade_out    = false;
			on_transition     = false;
			trans_from_screen = -1;
			trans_to_screen   = UNKNOWN;
		}
	}
}

// Draw transition effect (full-screen rectangle)
fn void draw_transition()
{
	rl::draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,
		rl::BLACK.fade(trans_alpha));
}

// Update and draw game frame
fn void update_draw_frame()
{
	float w = (float)rl::get_screen_width();
	float h = (float)rl::get_screen_height();

	// Calculate fitting scale ratio inline
	float scale = (w / SCREEN_WIDTH < h / SCREEN_HEIGHT) ? (w / SCREEN_WIDTH) : (h / SCREEN_HEIGHT);

	// Apply mouse scale and offset
	rl::set_mouse_scale(1.0f / scale, 1.0f / scale);
	rl::set_mouse_offset((int)((w - SCREEN_WIDTH * scale) * -0.5f), (int)((h - SCREEN_HEIGHT * scale) * -0.5f));

	if (rl::is_key_pressed(RLKeyboardKey.F) || rl::is_key_pressed(RLKeyboardKey.F11))
	{
		rl::toggle_fullscreen();
	}

	if (current_screen != CLICK_TO_PLAY)
	{
		rl::update_music_stream(music); // Keep music playing between screens
	}

	if (!on_transition)
	{
		switch (current_screen)
		{
			case CLICK_TO_PLAY:
				// 0 represents LEFT MOUSE BUTTON in Raylib's C API
				if (rl::is_mouse_button_pressed(RLMouseButton.LEFT) || rl::get_key_pressed())
				{
					rl::play_music_stream(music); // Start audio on interaction
					transition_to_screen(LOGO);
				}

			case LOGO:
				update_logo_screen();
				if (finish_logo_screen() != 0) transition_to_screen(TITLE);

			case TITLE:
				update_title_screen();
				if (finish_title_screen() == 1) { transition_to_screen(OPTIONS); }
				else if (finish_title_screen() == 2) { transition_to_screen(GAMEPLAY); }

			case OPTIONS:
				update_options_screen();
				if (finish_options_screen() != 0) transition_to_screen(TITLE);

			case GAMEPLAY:
				update_gameplay_screen();
				if (finish_gameplay_screen() == 1) transition_to_screen(ENDING);
				//else if (finish_gameplay_screen() == 2) transition_to_screen(TITLE);

			case ENDING:
				update_ending_screen();
				if (finish_ending_screen() == 1) transition_to_screen(TITLE);

			default: break;
		}
	}
	else { update_transition(); } // Update transition (fade-in, fade-out)
	//----------------------------------------------------------------------------------

	// Render to virtual texture at fixed SCREEN_WIDTHxSCREEN_HEIGHT
	//----------------------------------------------------------------------------------
	rl::begin_texture_mode(target_canvas);
		rl::clear_background(rl::RAYWHITE);

		switch (current_screen)
		{
			case CLICK_TO_PLAY:
				rl::draw_text("CLICK TO BEGIN",
					SCREEN_WIDTH / 2 - rl::measure_text("CLICK TO BEGIN", 20) / 2,
					SCREEN_HEIGHT / 2 - 10,
					20,
					rl::DARKGRAY);
			case LOGO:     draw_logo_screen();
			case TITLE:    draw_title_screen();
			case OPTIONS:  draw_options_screen();
			case GAMEPLAY: draw_gameplay_screen();
			case ENDING:   draw_ending_screen();
			default:       break;
		}

		// Draw full screen rectangle in front of everything
		if (on_transition) draw_transition();
	rl::end_texture_mode();

	// Render virtual texture to the actual window (scaling with letterbox/pillarbox)
	//----------------------------------------------------------------------------------
	rl::begin_drawing();
		rl::clear_background(rl::BLACK);

		// Source rectangle from virtual canvas
		// Note: OpenGL render textures are vertically flipped, so we use a negative height
		RLRectangle src_rec = { 0.0f, 0.0f, (float)target_canvas.texture.width, -(float)target_canvas.texture.height };

		// Centered destination rectangle
		RLRectangle dest_rec = {
			(w - ((float)SCREEN_WIDTH * scale)) * 0.5f,
			(h - ((float)SCREEN_HEIGHT * scale)) * 0.5f,
			(float)SCREEN_WIDTH * scale,
			(float)SCREEN_HEIGHT * scale
		};

		RLVector2 origin = { 0.0f, 0.0f };
		rl::draw_texture_pro(target_canvas.texture, src_rec, dest_rec, origin, 0.0f, rl::WHITE);

	rl::draw_fps((int)w - 80, 10);

	rl::end_drawing();
	//----------------------------------------------------------------------------------
}
