<script lang="ts">
  export let href: string
  export let text: string
</script>

<a {href} class={$$props.class} target="_blank" rel="noopener noreferrer"
  >{text}</a>
