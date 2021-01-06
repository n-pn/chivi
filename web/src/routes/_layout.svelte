<script>
  import { stores } from '@sapper/app'
  const { preloading } = stores()

  export let segment = ''

  import { onMount } from 'svelte'
  import { self_uname, self_power } from '$src/stores'

  onMount(async () => {
    const res = await fetch('/api/self')
    const data = await res.json()

    if (data._stt == 'ok') {
      $self_uname = data.uname
      $self_power = data.power
    }
  })
</script>

<div class="loader" class:_active={$preloading}>
  <svg class="spinner" viewBox="0 0 66 66" xmlns="http://www.w3.org/2000/svg">
    <circle
      class="path"
      fill="none"
      stroke-width="6"
      stroke-linecap="round"
      cx="33"
      cy="33"
      r="30" />
  </svg>
</div>

<div class="vessel">
  <slot {segment} />
</div>

<footer>
  <span>
    Trang web đang trong quá trình hoàn thiện, mọi ý kiến thắc mắc mời liên hệ
    tới một trong các địa chỉ sau:
  </span>

  <a
    class="link"
    href="https://voz.vn/t/truyen-tau-dich-may-mtl.95881/"
    target="_blank"
    rel="noreferer noopener">
    Vozforums
  </a>

  <a
    class="link"
    href="https://www.facebook.com/chivi.xyz/"
    target="_blank"
    rel="noreferer noopener">
    Facebook
  </a>

  <a
    class="link"
    href="https://discord.gg/mdC3KQH"
    target="_blank"
    rel="noreferer noopener">
    Discord
  </a>
</footer>

<style lang="scss">
  .vessel {
    flex: 1;
  }

  footer {
    width: 100%;
    text-align: center;
    padding: 0.75rem;
    @include font-size(2);
    @include fgcolor(neutral, 6);
    @include bgcolor(neutral, 2);
    @include border($sides: top);
  }

  .link {
    margin-left: 0.375rem;
    font-weight: 500;
    @include fgcolor(primary, 6);
    &:hover {
      @include fgcolor(primary, 4);
    }
  }

  :global(#sapper) {
    display: flex;
    flex-direction: column;
    min-height: 100%;
  }

  .loader {
    position: fixed;
    z-index: 99999;
    bottom: 0;
    right: 0;

    visibility: hidden;

    &._active {
      visibility: visible;
    }

    > svg {
      margin: 1rem;
      width: 2rem;
      height: 2rem;
    }
  }

  // Here is where the magic happens

  $offset: 187;
  $duration: 1.4s;

  .spinner {
    animation: rotator $duration linear infinite;
  }

  @keyframes rotator {
    0% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(270deg);
    }
  }

  .path {
    stroke-dasharray: $offset;
    stroke-dashoffset: 0;
    transform-origin: center;
    animation: dash $duration ease-in-out infinite,
      colors ($duration * 4) ease-in-out infinite;
  }

  @keyframes colors {
    0% {
      stroke: #4285f4;
    }
    25% {
      stroke: #de3e35;
    }
    50% {
      stroke: #f7c223;
    }
    75% {
      stroke: #1b9a59;
    }
    100% {
      stroke: #4285f4;
    }
  }

  @keyframes dash {
    0% {
      stroke-dashoffset: $offset;
    }
    50% {
      stroke-dashoffset: $offset/4;
      transform: rotate(135deg);
    }
    100% {
      stroke-dashoffset: $offset;
      transform: rotate(450deg);
    }
  }
</style>
