package com.example.devnote

import android.app.AlertDialog
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.activityViewModels
import com.example.devnote.data.Note
import com.example.devnote.data.NoteCategory
import com.example.devnote.data.NotePriority
import com.example.devnote.data.Project
import com.example.devnote.databinding.BottomSheetQuickNoteBinding
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.card.MaterialCardView

class QuickNoteBottomSheet : BottomSheetDialogFragment() {

    private var _binding: BottomSheetQuickNoteBinding? = null
    private val binding get() = _binding!!
    private val viewModel: DevNoteViewModel by activityViewModels()
    
    private var selectedProject: Project? = null
    private var projectsList: List<Project> = emptyList()

    private var currentCategory = NoteCategory.BUG_FIX
    private var currentPriority = NotePriority.MEDIUM

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = BottomSheetQuickNoteBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.allProjects.observe(viewLifecycleOwner) { projects ->
            projectsList = projects
            if (projects.isNotEmpty() && selectedProject == null) {
                // If there's a project and we haven't selected one, pick the first
                selectedProject = projects.first()
                updateProjectUI()
            }
        }

        binding.btnProjectSelector.setOnClickListener {
            showProjectPicker()
        }

        binding.cardCatBug.setOnClickListener { selectCategory(NoteCategory.BUG_FIX) }
        binding.cardCatFeature.setOnClickListener { selectCategory(NoteCategory.NEW_FEATURE) }

        binding.cardPrioLow.setOnClickListener { selectPriority(NotePriority.LOW) }
        binding.cardPrioMedium.setOnClickListener { selectPriority(NotePriority.MEDIUM) }
        binding.cardPrioHigh.setOnClickListener { selectPriority(NotePriority.HIGH) }

        // Initialize state
        selectCategory(NoteCategory.BUG_FIX)
        selectPriority(NotePriority.MEDIUM)

        binding.btnSave.setOnClickListener {
            if (selectedProject == null) {
                Toast.makeText(requireContext(), "Lütfen bir proje seçin", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            val content = binding.etNoteContent.text.toString().trim()
            if (content.isBlank()) {
                Toast.makeText(requireContext(), "Lütfen bir not yazın", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            val note = Note(
                projectId = selectedProject!!.id,
                content = content,
                priority = currentPriority,
                category = currentCategory
            )
            
            viewModel.insertNote(note)
            dismiss()
        }
    }

    private fun updateProjectUI() {
        if (selectedProject != null) {
            binding.tvSelectedProject.text = selectedProject!!.name
            binding.tvSelectedProject.setTextColor(Color.WHITE)
            binding.projectDot.backgroundTintList = ColorStateList.valueOf(Color.WHITE)
        } else {
            binding.tvSelectedProject.text = "Proje Seç"
            binding.tvSelectedProject.setTextColor(Color.parseColor("#80FFFFFF"))
            binding.projectDot.backgroundTintList = ColorStateList.valueOf(Color.parseColor("#4DFFFFFF"))
        }
    }

    private fun selectCategory(category: NoteCategory) {
        currentCategory = category
        updateCategoryCard(binding.cardCatBug, category == NoteCategory.BUG_FIX, "#E53935", binding.tvCatBug, binding.dotCatBug)
        updateCategoryCard(binding.cardCatFeature, category == NoteCategory.NEW_FEATURE, "#43A047", binding.tvCatFeature, binding.dotCatFeature)
    }

    private fun updateCategoryCard(card: MaterialCardView, isSelected: Boolean, activeColor: String, tv: android.widget.TextView, dot: View) {
        val colorInt = Color.parseColor(activeColor)
        if (isSelected) {
            card.setCardBackgroundColor(Color.parseColor("#26" + activeColor.substring(1))) // 0.15 alpha approx (0.15 * 255 = 38 -> 26 hex)
            card.strokeColor = Color.parseColor("#80" + activeColor.substring(1)) // 0.5 alpha
            card.strokeWidth = 3 // 1.5dp in px
            tv.setTextColor(colorInt)
            tv.setTypeface(null, Typeface.BOLD)
            dot.backgroundTintList = ColorStateList.valueOf(colorInt)
        } else {
            card.setCardBackgroundColor(Color.parseColor("#2A2A2A"))
            card.strokeColor = Color.parseColor("#14FFFFFF")
            card.strokeWidth = 2 // 1dp in px
            tv.setTextColor(Color.parseColor("#99FFFFFF"))
            tv.setTypeface(null, Typeface.NORMAL)
            dot.backgroundTintList = ColorStateList.valueOf(Color.parseColor("#99FFFFFF"))
        }
    }

    private fun selectPriority(priority: NotePriority) {
        currentPriority = priority
        updatePriorityCard(binding.cardPrioLow, priority == NotePriority.LOW, "#78909C", binding.tvPrioLow, 
            listOf(binding.bar1Low, binding.bar2Low, binding.bar3Low), 1)
        updatePriorityCard(binding.cardPrioMedium, priority == NotePriority.MEDIUM, "#FFA726", binding.tvPrioMedium, 
            listOf(binding.bar1Medium, binding.bar2Medium, binding.bar3Medium), 2)
        updatePriorityCard(binding.cardPrioHigh, priority == NotePriority.HIGH, "#EF5350", binding.tvPrioHigh, 
            listOf(binding.bar1High, binding.bar2High, binding.bar3High), 3)
    }

    private fun updatePriorityCard(card: MaterialCardView, isSelected: Boolean, activeColor: String, tv: android.widget.TextView, bars: List<View>, activeBarsCount: Int) {
        val colorInt = Color.parseColor(activeColor)
        val activeBarColor = if (isSelected) colorInt else Color.parseColor("#4DFFFFFF")
        val inactiveBarColor = Color.parseColor("#1AFFFFFF")

        bars.forEachIndexed { index, view ->
            view.setBackgroundColor(if (index < activeBarsCount) activeBarColor else inactiveBarColor)
        }

        if (isSelected) {
            card.setCardBackgroundColor(Color.parseColor("#1E" + activeColor.substring(1))) // 0.12 alpha approx
            card.strokeColor = Color.parseColor("#80" + activeColor.substring(1)) // 0.5 alpha
            card.strokeWidth = 3
            tv.setTextColor(colorInt)
            tv.setTypeface(null, Typeface.BOLD)
        } else {
            card.setCardBackgroundColor(Color.parseColor("#2A2A2A"))
            card.strokeColor = Color.parseColor("#14FFFFFF")
            card.strokeWidth = 2
            tv.setTextColor(Color.parseColor("#99FFFFFF"))
            tv.setTypeface(null, Typeface.NORMAL)
        }
    }

    private fun showProjectPicker() {
        val projectNames = projectsList.map { it.name }.toTypedArray()
        
        AlertDialog.Builder(requireContext(), android.R.style.Theme_Material_Dialog_Alert)
            .setTitle("Proje Seç")
            .setItems(projectNames) { _, which ->
                selectedProject = projectsList[which]
                updateProjectUI()
            }
            .setNegativeButton("İptal", null)
            .show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
