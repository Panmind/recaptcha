// Panmind Signup Form code - you can see it live on http://panmind.org/signup
//
$(document).ready (function () {
  // The AJAX Validate plugin is available on
  // http://github.com/Panmind/jquery-ajax-nav
  //
  $('#signup_form').ajaxValidate ({
    validate: {
      rules: {
        'user[name]':                  { required: true },
        'user[password]':              { required: true, minlength: 6 },
        'user[email]':                 { required: true, email: true },
        'user[password_confirmation]': { required: true, minlength: 6, equalTo: '#user_password' },
        'accept_terms':                { required: true },
        'recaptcha_response_field':    { required: true }
      }
    },

    params: function () {
      return {
        recaptcha_challenge_field: Recaptcha.get_challenge (),
        recaptcha_response_field : Recaptcha.get_response (),
        email                    : $('#user_email').val ()
      }
    },

    field: function () {
      // The server returns a 412 status if the Captcha failed
      // or a 406 if the user provided e-mail has already been
      // taken.
      //
      if (this.status == 412)
        return 'recaptcha_response_field';
      else
        return 'user[email]';
    },

    response: {
      '400': "The address you entered is not valid",
      '406': "This e-mail address has already been taken",
      '412': "Please try entering the words again"
    },

    error: function () {
      if (this.status == 412) // Captcha failed
        Recaptcha.reload ();
      else // Email failed
        $('#user_email').focus ()
    }
  });

  // Reset tabindex on ReCaptcha fields other than the text input,
  // for a seamless TAB experience.
  //
  $('#recaptcha_reload_btn, #recaptcha_switch_audio_btn, #recaptcha_switch_img_btn, #recaptcha_whatsthis_btn').each (function () {
    $(this).attr ('tabindex', -1);
  })

});
