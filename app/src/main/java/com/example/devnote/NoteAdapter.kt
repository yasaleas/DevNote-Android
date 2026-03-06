package com.example.devnote

import android.content.res.ColorStateList
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.devnote.data.NoteWithProject
import com.example.devnote.databinding.ItemNoteBinding

class NoteAdapter : ListAdapter<NoteWithProject, NoteAdapter.NoteViewHolder>(DiffCallback) {

    class NoteViewHolder(private val binding: ItemNoteBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(note: NoteWithProject) {
            binding.tvNoteProject.text = note.projectName
            binding.tvNoteContent.text = note.content
            binding.tvPriorityBadge.text = note.priority.label
            binding.tvCategory.text = note.category.label
            
            // Priority
            when (note.priority) {
                com.example.devnote.data.NotePriority.HIGH -> {
                    val color = Color.parseColor("#EF5350")
                    val bg = Color.parseColor("#1FEF5350")
                    binding.tvPriorityBadge.setTextColor(color)
                    binding.tvPriorityBadge.backgroundTintList = ColorStateList.valueOf(bg)
                }
                com.example.devnote.data.NotePriority.MEDIUM -> {
                    val color = Color.parseColor("#FFA726")
                    val bg = Color.parseColor("#1FFFA726")
                    binding.tvPriorityBadge.setTextColor(color)
                    binding.tvPriorityBadge.backgroundTintList = ColorStateList.valueOf(bg)
                }
                com.example.devnote.data.NotePriority.LOW -> {
                    val color = Color.parseColor("#78909C")
                    val bg = Color.parseColor("#1F78909C")
                    binding.tvPriorityBadge.setTextColor(color)
                    binding.tvPriorityBadge.backgroundTintList = ColorStateList.valueOf(bg)
                }
            }

            // Category
            when (note.category) {
                com.example.devnote.data.NoteCategory.BUG_FIX -> {
                    val color = Color.parseColor("#E53935")
                    val bg = Color.parseColor("#1AE53935")
                    binding.categoryDot.backgroundTintList = ColorStateList.valueOf(color)
                    binding.tvCategory.setTextColor(color)
                    binding.chipCategory.backgroundTintList = ColorStateList.valueOf(bg)
                }
                com.example.devnote.data.NoteCategory.NEW_FEATURE -> {
                    val color = Color.parseColor("#43A047")
                    val bg = Color.parseColor("#1A43A047")
                    binding.categoryDot.backgroundTintList = ColorStateList.valueOf(color)
                    binding.tvCategory.setTextColor(color)
                    binding.chipCategory.backgroundTintList = ColorStateList.valueOf(bg)
                }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): NoteViewHolder {
        val binding = ItemNoteBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return NoteViewHolder(binding)
    }

    override fun onBindViewHolder(holder: NoteViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    companion object {
        private val DiffCallback = object : DiffUtil.ItemCallback<NoteWithProject>() {
            override fun areItemsTheSame(oldItem: NoteWithProject, newItem: NoteWithProject): Boolean {
                return oldItem.id == newItem.id
            }

            override fun areContentsTheSame(oldItem: NoteWithProject, newItem: NoteWithProject): Boolean {
                return oldItem == newItem
            }
        }
    }
}
