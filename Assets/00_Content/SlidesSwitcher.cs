using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class SlidesSwitcher : MonoBehaviour
{

    [SerializeField] private PlayableDirector director;
    [SerializeField] private TimelineAsset[]  slides;
    
    [SerializeField] private InputActionReference nextSlide;
    [SerializeField] private InputActionReference previousSlide;

    private int _currentSlideIndex;
    
    private TimelineAsset CurrentSlide => slides[Mathf.Clamp(_currentSlideIndex, min: 0, max: slides.Length - 1)];

    private void OnEnable()
    {
        if(nextSlide != null)
        {
            if (nextSlide.action != null)
            {
                nextSlide.action.Enable();
            }
        }

        if(previousSlide != null)
        {
            if (previousSlide.action != null)
            {
                previousSlide.action.Enable();
            }
        }
    }
    
    private void OnDisable()
    {
        if(nextSlide != null)
        {
            if (nextSlide.action != null)
            {
                nextSlide.action.Disable();
            }
        }

        if(previousSlide != null)
        {
            if (previousSlide.action != null)
            {
                previousSlide.action.Disable();
            }
        }
    }

    private void Awake()
    {
        _currentSlideIndex = 0;
    }

    private void Start()
    {
        if (nextSlide != null)
        {
            if (nextSlide.action != null)
            {
                nextSlide.action.performed += OnNextSlide;
            }
        }

        if (previousSlide != null)
        {
            if (previousSlide.action != null)
            {
                previousSlide.action.performed += OnPreviousSlide;
            }
        }
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            OnNextSlide(default);
        }
        else if (Input.GetMouseButtonDown(1))
        {
            OnPreviousSlide(default);
        }
    }

    private void OnPreviousSlide(InputAction.CallbackContext obj)
    {
        _currentSlideIndex--;

        if (CurrentSlide != null)
        {
            // director.playableAsset = CurrentSlide;
            // director.time = 0;
            director.Play(CurrentSlide);
        }
    }

    private void OnNextSlide(InputAction.CallbackContext obj)
    {
        bool isLastSlide = _currentSlideIndex == slides.Length - 1;
        
        if (isLastSlide)
        {
            return;
        }
        
        _currentSlideIndex++;
        
        if (CurrentSlide != null)
        {
            // director.playableAsset = CurrentSlide;
            // director.time = 0;
            director.Play(CurrentSlide);
        }
    }
}
