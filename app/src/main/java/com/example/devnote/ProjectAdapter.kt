package com.example.devnote

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.devnote.data.ProjectWithNotesCount
import com.example.devnote.databinding.ItemProjectBinding
import com.example.devnote.databinding.ItemProjectHeaderBinding

sealed class ProjectListItem {
    data class Header(val title: String, val isGithub: Boolean) : ProjectListItem()
    data class Project(val data: ProjectWithNotesCount) : ProjectListItem()
    data object GithubPrompt : ProjectListItem()
}

class ProjectAdapter(
    private val onProjectLongClick: (ProjectWithNotesCount) -> Unit,
    private val onGithubPromptClick: () -> Unit
) : ListAdapter<ProjectListItem, RecyclerView.ViewHolder>(ProjectDiffCallback()) {

    companion object {
        const val TYPE_HEADER = 0
        const val TYPE_PROJECT = 1
        const val TYPE_GITHUB_PROMPT = 2
    }

    override fun getItemViewType(position: Int): Int {
        return when(getItem(position)) {
            is ProjectListItem.Header -> TYPE_HEADER
            is ProjectListItem.Project -> TYPE_PROJECT
            is ProjectListItem.GithubPrompt -> TYPE_GITHUB_PROMPT
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return when (viewType) {
            TYPE_HEADER -> {
                val binding = ItemProjectHeaderBinding.inflate(inflater, parent, false)
                HeaderViewHolder(binding)
            }
            TYPE_PROJECT -> {
                val binding = ItemProjectBinding.inflate(inflater, parent, false)
                ProjectViewHolder(binding)
            }
            TYPE_GITHUB_PROMPT -> {
                val view = inflater.inflate(R.layout.item_github_prompt, parent, false)
                GithubPromptViewHolder(view)
            }
            else -> throw IllegalArgumentException("Invalid view type")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (val item = getItem(position)) {
            is ProjectListItem.Header -> (holder as HeaderViewHolder).bind(item)
            is ProjectListItem.Project -> (holder as ProjectViewHolder).bind(item)
            is ProjectListItem.GithubPrompt -> {
                holder.itemView.setOnClickListener {
                    onGithubPromptClick()
                }
            }
        }
    }

    inner class HeaderViewHolder(private val binding: ItemProjectHeaderBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(header: ProjectListItem.Header) {
            binding.tvHeaderTitle.text = header.title
            if (header.isGithub) {
                binding.ivHeaderIcon.setImageResource(R.drawable.ic_code)
            } else {
                binding.ivHeaderIcon.setImageResource(R.drawable.ic_folder)
            }
        }
    }

    class GithubPromptViewHolder(view: View) : RecyclerView.ViewHolder(view)

    inner class ProjectViewHolder(private val binding: ItemProjectBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(item: ProjectListItem.Project) {
            val project = item.data
            binding.tvProjectName.text = project.name
            binding.tvNoteCount.text = "${project.noteCount} not"

            if (project.isGithubRepo) {
                binding.projectIconBg.setImageResource(R.drawable.ic_code)
                binding.projectIconBg.backgroundTintList = android.content.res.ColorStateList.valueOf(android.graphics.Color.parseColor("#14FFFFFF"))

                binding.llGithubLang.visibility = View.VISIBLE
                binding.tvLanguage.text = project.githubLanguage
                
                // Color dots based on language
                val dotColor = when(project.githubLanguage?.lowercase()) {
                    "dart" -> "#00B4AB"
                    "javascript" -> "#F1E05A"
                    "typescript" -> "#3178C6"
                    "python" -> "#3572A5"
                    "java" -> "#B07219"
                    "kotlin" -> "#A97BFF"
                    "swift" -> "#FF6F43"
                    "c++" -> "#F34B7D"
                    "c#" -> "#178600"
                    "go" -> "#00ADD8"
                    "rust" -> "#DEA584"
                    "ruby" -> "#701516"
                    "php" -> "#4F5D95"
                    "html" -> "#E34C26"
                    "css" -> "#563D7C"
                    else -> "#60FFFFFF"
                }
                binding.langDot.backgroundTintList = android.content.res.ColorStateList.valueOf(
                    android.graphics.Color.parseColor(dotColor)
                )
            } else {
                binding.projectIconBg.setImageResource(R.drawable.ic_folder)
                binding.projectIconBg.backgroundTintList = android.content.res.ColorStateList.valueOf(android.graphics.Color.parseColor("#0FFFFFFF"))
                binding.llGithubLang.visibility = View.GONE
            }

            binding.root.setOnLongClickListener {
                onProjectLongClick(project)
                true
            }
        }
    }

    class ProjectDiffCallback : DiffUtil.ItemCallback<ProjectListItem>() {
        override fun areItemsTheSame(oldItem: ProjectListItem, newItem: ProjectListItem): Boolean {
            if (oldItem is ProjectListItem.Header && newItem is ProjectListItem.Header) {
                return oldItem.title == newItem.title
            }
            if (oldItem is ProjectListItem.Project && newItem is ProjectListItem.Project) {
                return oldItem.data.id == newItem.data.id
            }
            if (oldItem is ProjectListItem.GithubPrompt && newItem is ProjectListItem.GithubPrompt) {
                return true
            }
            return false
        }

        override fun areContentsTheSame(oldItem: ProjectListItem, newItem: ProjectListItem): Boolean {
            return oldItem == newItem
        }
    }
}
