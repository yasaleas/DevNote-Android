package com.example.devnote

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.text.InputType
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.example.devnote.data.network.RetrofitInstance
import com.example.devnote.databinding.ActivityGithubSettingsBinding
import com.example.devnote.databinding.ItemGithubStepBinding
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.URL

class GithubSettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityGithubSettingsBinding
    private val viewModel: DevNoteViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityGithubSettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationIcon(R.drawable.ic_arrow_back)
        binding.toolbar.setNavigationOnClickListener { finish() }

        setupSteps()
        updateUI()

        binding.btnConnect.setOnClickListener {
            connectGithub()
        }

        binding.tvOpenGithubLink.setOnClickListener {
            val url = "https://github.com/settings/tokens/new"
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("GitHub Token URL", url)
            clipboard.setPrimaryClip(clip)
            
            Toast.makeText(this, "Link kopyalandı! Tarayıcıda açın.", Toast.LENGTH_SHORT).show()
            
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            startActivity(intent)
        }

        binding.cardRefresh.setOnClickListener {
            refreshRepos()
        }

        binding.cardDisconnect.setOnClickListener {
            disconnectGithub()
        }

        binding.tilToken.setEndIconOnClickListener {
            val isPassword = binding.etToken.inputType == (InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD)
            if (isPassword) {
                binding.etToken.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD
                binding.tilToken.setEndIconDrawable(R.drawable.ic_visibility_off)
            } else {
                binding.etToken.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD
                binding.tilToken.setEndIconDrawable(R.drawable.ic_visibility)
            }
            binding.etToken.setSelection(binding.etToken.text?.length ?: 0)
        }
    }

    private fun updateUI() {
        val prefs = getSharedPreferences("DevNotePrefs", Context.MODE_PRIVATE)
        val token = prefs.getString("GITHUB_TOKEN", "")

        if (token.isNullOrEmpty()) {
            binding.viewFlipper.displayedChild = 0 // Connect View
        } else {
            binding.viewFlipper.displayedChild = 1 // Connected View
            val username = prefs.getString("GITHUB_USERNAME", "")
            val avatarUrl = prefs.getString("GITHUB_AVATAR_URL", "")
            
            binding.tvUsername.text = username

            if (!avatarUrl.isNullOrEmpty()) {
                binding.ivAvatar.loadUrl(avatarUrl)
            } else {
                binding.ivAvatar.setImageResource(R.drawable.ic_code) // fallback
            }

            viewModel.allProjectsWithCount.observe(this) { projects ->
                val count = projects.count { it.isGithubRepo }
                binding.tvRepoCount.text = "$count repo bağlı"
            }
        }
    }

    private fun connectGithub() {
        val token = binding.etToken.text.toString().trim()
        if (token.isEmpty()) {
            binding.tvError.visibility = View.VISIBLE
            binding.tvError.text = "Lütfen bir token girin"
            return
        }
        binding.tvError.visibility = View.GONE

        // Show loading
        binding.btnConnect.text = ""
        binding.btnConnect.isEnabled = false
        binding.pbLoading.visibility = View.VISIBLE

        lifecycleScope.launch {
            try {
                val authHeader = if (token.startsWith("Bearer ") || token.startsWith("Token ")) token else "Bearer $token"
                
                val user = withContext(Dispatchers.IO) {
                    RetrofitInstance.api.getAuthenticatedUser(authHeader)
                }

                val prefs = getSharedPreferences("DevNotePrefs", Context.MODE_PRIVATE)
                prefs.edit()
                    .putString("GITHUB_TOKEN", token)
                    .putString("GITHUB_USERNAME", user.login)
                    .putString("GITHUB_AVATAR_URL", user.avatarUrl ?: "")
                    .apply()

                viewModel.fetchGithubRepos(token)

                binding.etToken.text?.clear()
                updateUI()

            } catch (e: Exception) {
                binding.tvError.visibility = View.VISIBLE
                binding.tvError.text = "Bağlantı başarısız: Yetkisiz veya geçersiz token."
                e.printStackTrace()
            } finally {
                binding.btnConnect.text = "Bağlan"
                binding.btnConnect.isEnabled = true
                binding.pbLoading.visibility = View.GONE
            }
        }
    }

    private fun refreshRepos() {
        val prefs = getSharedPreferences("DevNotePrefs", Context.MODE_PRIVATE)
        val token = prefs.getString("GITHUB_TOKEN", "")
        if (!token.isNullOrEmpty()) {
            viewModel.fetchGithubRepos(token)
            Toast.makeText(this, "Repolar güncellendi", Toast.LENGTH_SHORT).show()
        }
    }

    private fun disconnectGithub() {
        MaterialAlertDialogBuilder(this)
            .setTitle("GitHub Bağlantısını Kes")
            .setMessage("GitHub hesabının bağlantısı kesilecek ve tüm GitHub repoları projeler listesinden kaldırılacak. Devam etmek istiyor musun?")
            .setPositiveButton("Kes") { _, _ ->
                val prefs = getSharedPreferences("DevNotePrefs", Context.MODE_PRIVATE)
                prefs.edit()
                    .remove("GITHUB_TOKEN")
                    .remove("GITHUB_USERNAME")
                    .remove("GITHUB_AVATAR_URL")
                    .apply()

                // Remove GitHub Repos from Database
                viewModel.allProjectsWithCount.value?.let { projects ->
                    projects.filter { it.isGithubRepo }.forEach { repo ->
                        viewModel.deleteProject(repo.id)
                    }
                }

                updateUI()
            }
            .setNegativeButton("İptal", null)
            .show()
    }

    private fun setupSteps() {
        setStepContent(binding.step1, "1", "GitHub → Settings → Developer settings")
        setStepContent(binding.step2, "2", "Personal access tokens → Tokens (classic)")
        setStepContent(binding.step3, "3", "Generate new token → \"repo\" iznini seç")
        setStepContent(binding.step4, "4", "Token'ı kopyala ve yukarıya yapıştır")
    }

    private fun setStepContent(stepBinding: ItemGithubStepBinding, number: String, text: String) {
        stepBinding.tvStepNumber.text = number
        stepBinding.tvStepText.text = text
    }
}

fun ImageView.loadUrl(url: String) {
    kotlinx.coroutines.GlobalScope.launch(Dispatchers.IO) {
        try {
            val inputStream = URL(url).openStream()
            val bitmap = BitmapFactory.decodeStream(inputStream)
            withContext(Dispatchers.Main) {
                this@loadUrl.setImageBitmap(bitmap)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
