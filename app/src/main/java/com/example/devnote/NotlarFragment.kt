package com.example.devnote

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.devnote.databinding.FragmentNotlarBinding

class NotlarFragment : Fragment() {
    private var _binding: FragmentNotlarBinding? = null
    private val binding get() = _binding!!

    private val viewModel: DevNoteViewModel by activityViewModels()
    private lateinit var adapter: NoteAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentNotlarBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        adapter = NoteAdapter()
        binding.recyclerViewNotes.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerViewNotes.adapter = adapter

        viewModel.allNotesWithProject.observe(viewLifecycleOwner) { notes ->
            if (notes.isEmpty()) {
                binding.emptyStateView.visibility = View.VISIBLE
                binding.recyclerViewNotes.visibility = View.GONE
            } else {
                binding.emptyStateView.visibility = View.GONE
                binding.recyclerViewNotes.visibility = View.VISIBLE
                adapter.submitList(notes)
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
