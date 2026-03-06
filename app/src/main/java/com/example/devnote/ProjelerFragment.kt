package com.example.devnote

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.devnote.databinding.FragmentProjelerBinding

class ProjelerFragment : Fragment() {
    private var _binding: FragmentProjelerBinding? = null
    private val binding get() = _binding!!

    private val viewModel: DevNoteViewModel by activityViewModels()
    private lateinit var adapter: ProjectAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProjelerBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        adapter = ProjectAdapter(
            onProjectLongClick = { project -> showDeleteDialog(project) },
            onGithubPromptClick = { showGithubAuth() }
        )
        binding.recyclerViewProjects.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerViewProjects.adapter = adapter

        updateGithubIconColor()

        binding.btnLinkGithub.setOnClickListener {
            showGithubAuth()
        }

        viewModel.allProjectsWithCount.observe(viewLifecycleOwner) { projects ->
            val items = mutableListOf<ProjectListItem>()
            
            val localProjects = projects.filter { !it.isGithubRepo }
            val githubProjects = projects.filter { it.isGithubRepo }

            if (localProjects.isEmpty() && githubProjects.isEmpty()) {
                binding.emptyStateView.visibility = View.VISIBLE
                binding.recyclerViewProjects.visibility = View.GONE
            } else {
                binding.emptyStateView.visibility = View.GONE
                binding.recyclerViewProjects.visibility = View.VISIBLE

                if (localProjects.isNotEmpty()) {
                    items.add(ProjectListItem.Header("Yerel Projeler", false))
                    items.addAll(localProjects.map { ProjectListItem.Project(it) })
                }

                if (githubProjects.isNotEmpty()) {
                    items.add(ProjectListItem.Header("GitHub Repoları", true))
                    items.addAll(githubProjects.map { ProjectListItem.Project(it) })
                }

                val prefs = requireContext().getSharedPreferences("DevNotePrefs", android.content.Context.MODE_PRIVATE)
                val token = prefs.getString("GITHUB_TOKEN", "")
                if (token.isNullOrEmpty() && githubProjects.isEmpty()) {
                    items.add(ProjectListItem.GithubPrompt)
                }
            }

            adapter.submitList(items)
        }
    }

    private fun showGithubAuth() {
        val intent = android.content.Intent(requireContext(), GithubSettingsActivity::class.java)
        startActivity(intent)
    }

    override fun onResume() {
        super.onResume()
        updateGithubIconColor()
    }

    private fun updateGithubIconColor() {
        val prefs = requireContext().getSharedPreferences("DevNotePrefs", android.content.Context.MODE_PRIVATE)
        val token = prefs.getString("GITHUB_TOKEN", "")
        if (!token.isNullOrEmpty()) {
            binding.btnLinkGithub.backgroundTintList = android.content.res.ColorStateList.valueOf(android.graphics.Color.parseColor("#15241C"))
            binding.btnLinkGithub.imageTintList = android.content.res.ColorStateList.valueOf(android.graphics.Color.parseColor("#34C759"))
        } else {
            binding.btnLinkGithub.backgroundTintList = android.content.res.ColorStateList.valueOf(android.graphics.Color.parseColor("#0FFFFFFF"))
            binding.btnLinkGithub.imageTintList = android.content.res.ColorStateList.valueOf(android.graphics.Color.parseColor("#80FFFFFF"))
        }
    }

    private fun showDeleteDialog(project: com.example.devnote.data.ProjectWithNotesCount) {
        com.google.android.material.dialog.MaterialAlertDialogBuilder(requireContext())
            .setTitle("Projeyi Sil")
            .setMessage("'${project.name}' adlı projeyi silmek istediğinize emin misiniz? Bu işlem projeye ait tüm notları da silecektir.")
            .setPositiveButton("Sil") { dialog, _ ->
                viewModel.deleteProject(project.id)
                dialog.dismiss()
            }
            .setNegativeButton("İptal") { dialog, _ ->
                dialog.cancel()
            }
            .show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
