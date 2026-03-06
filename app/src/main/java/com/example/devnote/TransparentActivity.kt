package com.example.devnote

import android.app.AlertDialog
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.view.View
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.example.devnote.data.Note
import com.example.devnote.data.NoteCategory
import com.example.devnote.data.NotePriority
import com.example.devnote.data.Project
import com.example.devnote.databinding.ActivityTransparentBinding
import com.example.devnote.databinding.BottomSheetQuickNoteBinding
import com.google.android.material.card.MaterialCardView

class TransparentActivity : AppCompatActivity() {

    private lateinit var binding: ActivityTransparentBinding
    private lateinit var bottomSheetBinding: BottomSheetQuickNoteBinding
    private val viewModel: DevNoteViewModel by viewModels()

    private var selectedProject: Project? = null
    private var projectsList: List<Project> = emptyList()

    private var currentCategory = NoteCategory.BUG_FIX
    private var currentPriority = NotePriority.MEDIUM
    
    private var isClosing = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Disable enter transitions
        overridePendingTransition(0, 0)
        
        binding = ActivityTransparentBinding.inflate(layoutInflater)
        setContentView(binding.root)

        bottomSheetBinding = binding.bottomSheetContent

        binding.transparentBackground.setOnClickListener {
            closeActivity()
        }
        
        // Block clicks on the sheet from bubbling up and closing activity
        bottomSheetBinding.root.setOnClickListener { }

        viewModel.allProjects.observe(this) { projects ->
            projectsList = projects
            if (projects.isNotEmpty() && selectedProject == null) {
                // If there's a project and we haven't selected one, pick the first
                selectedProject = projects.first()
                updateProjectUI()
            }
        }

        bottomSheetBinding.btnProjectSelector.setOnClickListener {
            showProjectPicker()
        }

        bottomSheetBinding.cardCatBug.setOnClickListener { selectCategory(NoteCategory.BUG_FIX) }
        bottomSheetBinding.cardCatFeature.setOnClickListener { selectCategory(NoteCategory.NEW_FEATURE) }

        bottomSheetBinding.cardPrioLow.setOnClickListener { selectPriority(NotePriority.LOW) }
        bottomSheetBinding.cardPrioMedium.setOnClickListener { selectPriority(NotePriority.MEDIUM) }
        bottomSheetBinding.cardPrioHigh.setOnClickListener { selectPriority(NotePriority.HIGH) }

        // Initialize state
        selectCategory(NoteCategory.BUG_FIX)
        selectPriority(NotePriority.MEDIUM)

        bottomSheetBinding.btnSave.setOnClickListener {
            if (selectedProject == null) {
                Toast.makeText(this, "Lütfen bir proje seçin", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            val content = bottomSheetBinding.etNoteContent.text.toString().trim()
            if (content.isBlank()) {
                Toast.makeText(this, "Lütfen bir not yazın", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            val note = Note(
                projectId = selectedProject!!.id,
                content = content,
                priority = currentPriority,
                category = currentCategory
            )
            
            viewModel.insertNote(note)
            closeActivity()
        }

        // Wait to show view after layout for the animation
        bottomSheetBinding.root.post {
            val slideUp = AnimationUtils.loadAnimation(this, R.anim.slide_up_anim)
            bottomSheetBinding.root.startAnimation(slideUp)
            bottomSheetBinding.root.visibility = android.view.View.VISIBLE
        }
    }

    private fun updateProjectUI() {
        if (selectedProject != null) {
            bottomSheetBinding.tvSelectedProject.text = selectedProject!!.name
            bottomSheetBinding.tvSelectedProject.setTextColor(Color.WHITE)
            bottomSheetBinding.projectDot.backgroundTintList = ColorStateList.valueOf(Color.WHITE)
        } else {
            bottomSheetBinding.tvSelectedProject.text = "Proje Seç"
            bottomSheetBinding.tvSelectedProject.setTextColor(Color.parseColor("#80FFFFFF"))
            bottomSheetBinding.projectDot.backgroundTintList = ColorStateList.valueOf(Color.parseColor("#4DFFFFFF"))
        }
    }

    private fun selectCategory(category: NoteCategory) {
        currentCategory = category
        updateCategoryCard(bottomSheetBinding.cardCatBug, category == NoteCategory.BUG_FIX, "#E53935", bottomSheetBinding.tvCatBug, bottomSheetBinding.dotCatBug)
        updateCategoryCard(bottomSheetBinding.cardCatFeature, category == NoteCategory.NEW_FEATURE, "#43A047", bottomSheetBinding.tvCatFeature, bottomSheetBinding.dotCatFeature)
    }

    private fun updateCategoryCard(card: MaterialCardView, isSelected: Boolean, activeColor: String, tv: android.widget.TextView, dot: View) {
        val colorInt = Color.parseColor(activeColor)
        if (isSelected) {
            card.setCardBackgroundColor(Color.parseColor("#26" + activeColor.substring(1)))
            card.strokeColor = Color.parseColor("#80" + activeColor.substring(1))
            card.strokeWidth = 3
            tv.setTextColor(colorInt)
            tv.setTypeface(null, Typeface.BOLD)
            dot.backgroundTintList = ColorStateList.valueOf(colorInt)
        } else {
            card.setCardBackgroundColor(Color.parseColor("#2A2A2A"))
            card.strokeColor = Color.parseColor("#14FFFFFF")
            card.strokeWidth = 2
            tv.setTextColor(Color.parseColor("#99FFFFFF"))
            tv.setTypeface(null, Typeface.NORMAL)
            dot.backgroundTintList = ColorStateList.valueOf(Color.parseColor("#99FFFFFF"))
        }
    }

    private fun selectPriority(priority: NotePriority) {
        currentPriority = priority
        updatePriorityCard(bottomSheetBinding.cardPrioLow, priority == NotePriority.LOW, "#78909C", bottomSheetBinding.tvPrioLow, 
            listOf(bottomSheetBinding.bar1Low, bottomSheetBinding.bar2Low, bottomSheetBinding.bar3Low), 1)
        updatePriorityCard(bottomSheetBinding.cardPrioMedium, priority == NotePriority.MEDIUM, "#FFA726", bottomSheetBinding.tvPrioMedium, 
            listOf(bottomSheetBinding.bar1Medium, bottomSheetBinding.bar2Medium, bottomSheetBinding.bar3Medium), 2)
        updatePriorityCard(bottomSheetBinding.cardPrioHigh, priority == NotePriority.HIGH, "#EF5350", bottomSheetBinding.tvPrioHigh, 
            listOf(bottomSheetBinding.bar1High, bottomSheetBinding.bar2High, bottomSheetBinding.bar3High), 3)
    }

    private fun updatePriorityCard(card: MaterialCardView, isSelected: Boolean, activeColor: String, tv: android.widget.TextView, bars: List<View>, activeBarsCount: Int) {
        val colorInt = Color.parseColor(activeColor)
        val activeBarColor = if (isSelected) colorInt else Color.parseColor("#4DFFFFFF")
        val inactiveBarColor = Color.parseColor("#1AFFFFFF")

        bars.forEachIndexed { index, view ->
            view.setBackgroundColor(if (index < activeBarsCount) activeBarColor else inactiveBarColor)
        }

        if (isSelected) {
            card.setCardBackgroundColor(Color.parseColor("#1E" + activeColor.substring(1)))
            card.strokeColor = Color.parseColor("#80" + activeColor.substring(1))
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
        
        AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog_Alert)
            .setTitle("Proje Seç")
            .setItems(projectNames) { _, which ->
                selectedProject = projectsList[which]
                updateProjectUI()
            }
            .setNegativeButton("İptal", null)
            .show()
    }

    private fun closeActivity() {
        if (isClosing) return
        isClosing = true
        
        val slideDown = AnimationUtils.loadAnimation(this, R.anim.slide_down_anim)
        slideDown.setAnimationListener(object : Animation.AnimationListener {
            override fun onAnimationStart(animation: Animation?) {}
            override fun onAnimationEnd(animation: Animation?) {
                bottomSheetBinding.root.visibility = android.view.View.INVISIBLE
                finish()
                overridePendingTransition(0, 0)
            }
            override fun onAnimationRepeat(animation: Animation?) {}
        })
        bottomSheetBinding.root.startAnimation(slideDown)
    }

    @Deprecated("Deprecated in Java", ReplaceWith("closeActivity()"))
    override fun onBackPressed() {
        closeActivity()
    }
}
