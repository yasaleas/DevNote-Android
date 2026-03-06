package com.example.devnote

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.example.devnote.databinding.BottomSheetGithubAuthBinding

class GithubAuthBottomSheet(private val onTokenSubmit: (String) -> Unit) : BottomSheetDialogFragment() {

    private var _binding: BottomSheetGithubAuthBinding? = null
    private val binding get() = _binding!!

    override fun getTheme(): Int = R.style.Theme_DevNote_BottomSheet

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = BottomSheetGithubAuthBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Set existing token if any
        val prefs = requireContext().getSharedPreferences("DevNotePrefs", Context.MODE_PRIVATE)
        val existingToken = prefs.getString("GITHUB_TOKEN", "")
        if (!existingToken.isNullOrEmpty()) {
            binding.etToken.setText(existingToken)
            binding.btnConnect.text = "Senkronize Et (Bağlı)"
        }

        binding.btnConnect.setOnClickListener {
            val token = binding.etToken.text.toString().trim()
            if (token.isEmpty()) {
                Toast.makeText(requireContext(), "Lütfen bir GitHub Token girin", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            prefs.edit().putString("GITHUB_TOKEN", token).apply()
            onTokenSubmit(token)
            dismiss()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
