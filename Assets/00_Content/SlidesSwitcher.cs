using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class SlidesSwitcher : MonoBehaviour
{

    [SerializeField] private PlayableDirector director;
    [SerializeField] private TimelineAsset[]  slides;
    
    [SerializeField] private InputActionReference nextSlide;
    [SerializeField] private InputActionAsset previousSlide;

    private int _currentSlideIndex;
    
    private TimelineAsset CurrentSlide => slides[_currentSlideIndex];

    private void OnEnable()
    {
        nextSlide.action.Enable();
        previousSlide.Enable();
    }
    
    private void OnDisable()
    {
        nextSlide.action.Disable();
        previousSlide.Disable();
    }

    private void Start()
    {
        nextSlide.action.performed += OnNextSlide;
        //previousSlide.performed += OnPreviousSlide;
    }

    private void OnPreviousSlide(InputAction.CallbackContext obj)
    {
        _currentSlideIndex--;
        
        director.playableAsset = CurrentSlide;
    }

    private void OnNextSlide(InputAction.CallbackContext obj)
    {
        _currentSlideIndex++;
        
        director.playableAsset = CurrentSlide;
    }
}
