package com.example.devnote

import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.example.devnote.data.Project
import com.example.devnote.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val viewModel: DevNoteViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Add mock data if empty
        viewModel.allProjects.observe(this) { projects ->
            if (projects.isEmpty()) {
                viewModel.insertProject(Project(name = "DevNote App", isGithubRepo = false))
                viewModel.insertProject(Project(name = "GitHub Repo", isGithubRepo = true, githubLanguage = "Kotlin"))
            }
            viewModel.allProjects.removeObservers(this)
        }

        binding.bottomNavigation.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.nav_notes -> {
                    loadFragment(NotlarFragment())
                    true
                }
                R.id.nav_projects -> {
                    loadFragment(ProjelerFragment())
                    true
                }
                else -> false
            }
        }

        binding.fabAddNote.setOnClickListener {
            QuickNoteBottomSheet().show(supportFragmentManager, "QuickNote")
        }

        if (savedInstanceState == null) {
            binding.bottomNavigation.selectedItemId = R.id.nav_notes
        }
    }

    private fun loadFragment(fragment: Fragment) {
        supportFragmentManager.beginTransaction()
            .replace(R.id.fragment_container, fragment)
            .commit()
    }
}